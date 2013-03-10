module UpdateOrInsert
  def self.included(base)
    base.extend(ClassMethods)
  end

  class UpdateError < StandardError ; end
  class InsertError < StandardError ; end

  # Forward declarations
  class Base ; end
  class PostgreSQL < Base ; end
  class MySql < Base ; end
  class SQLite < Base ; end

  # ================================================================
  module ClassMethods

    DEFAULT_OPTIONS = {
      :on_update => :all,
      :on_insert => :all,
      :db_adapter => :default,
      :within_transaction => true
    }

    DB_ADAPTERS = {
      :default => :default, 
      :postgres => PostgreSQL, 
      :mysql => MySql, 
      :sqlite => SQLite
    }

    
    # Create new records or update incumbent records from a list of
    # candidate records.  For example:
    #
    #   MyModel.update_or_insert(candidates, conditions = :none, options = {})
    #
    # where 
    #
    #   conditions determine which fields are used in a query to find
    #   incumbent records.  It may be:
    #
    #     [], nil, :none              # don't query for incumbents, create only [default]
    #     :all	                      # use all fields from candidate
    #     [:field1, :field2, ...]     # use selected fields in query
    #
    #   options can be:
    # 
    #     :on_update => on_update_options
    #     :on_insert => on_insert_options
    #     :db_adapter => db_adapter_options
    #
    #   on_update_options determines what happens on a match.  it can be
    #
    #     :all                        # update all fields of incumbent from candidate (default)
    #     :error                      # raise an error
    #     :ignore                     # take no action
    #     [:field1, :field2 ...]      # update selected fields of incumbent from candidate
    #
    #   on_insert_options determines what happens when there isn't a match.  it can be
    #
    #     :all                        # create a record using all fields from candidate (default)
    #     :error                      # raise an error
    #     :ignore                     # take no action 
    #     [:field1, :field2, ...]     # populate new record with selected fields from candidate
    #   
    #   db_adapter_options can be:
    #
    #     :generic                    # use generic methods (default)
    #     :default                    # use the existing database adapter
    #     :postgresql
    #     :mysql
    #     :sqlite

    def update_or_insert(candidates, conditions = :none, options = {})
      options = DEFAULT_OPTIONS.merge(options)
      validate_args(candidates, conditions, options)
      loader_class = get_loader_class(options[:db_adapter])
      loader_class.new(self, candidates, conditions, options).update_or_insert
    end

private

    def validate_args(candidates, conditions, options)
      validate_candidates_arg(candidates)
      validate_conditions_arg(conditions)
      validate_options(options)
    end

    def validate_candidates_arg(candidates)
      raise ArgumentError.new("candidates must be enumerable, found #{candidates}") unless candidates.kind_of?(Enumerable)
      candidates
    end

    def validate_conditions_arg(conditions)
      if [nil, :none, :all].member?(conditions)
      elsif conditions.kind_of?(Enumerable)
        unless conditions.all? {|condition| condition.respond_to?(:to_sym)}
          raise ArgumentError.new("all members of conditions must be coercable to symbol")
        end
      else
        raise ArgumentError.new("conditions must be one of [nil, :none, :all] or an enumerable, found #{conditions}")
      end
    end

    def validate_options(options)
      raise ArgumentError.new("options must be a hash, found #{options}") unless options.kind_of?(Hash)
      validate_keys(options, DEFAULT_OPTIONS)
      validate_action(options, :on_update)
      validate_action(options, :on_insert)
      valid_db_adapters = [:generic, :default, :postgresql, :mysql, :sqlite]
      unless valid_db_adapters.member?(options[:db_adapter])
        raise ArgumentError.new(":db_adapter must be one of #{valid_db_adapters}, found #{options[:db_adapter]}")
      end
    end

    def validate_keys(hash, default_hash)
      invalid_keys = hash.keys - default_hash.keys
      raise ArgumentError.new("options keys must be one of #{default_hash.keys}, found #{invalid_keys}") if invalid_keys.length > 0
    end

    def validate_action(options, key)
      val = options[key]
      valid_values = [:ignore, :error, :all]
      if valid_values.member?(val)
      elsif val.kind_of?(Enumerable)
        raise ArgumentError.new("all members of #{key} must be coercible to symbol") unless val.all? {|v| v.respond_to?(:to_sym)}
      else
        raise ArgumentError.new("#{key} must be #{valid_values} or an enumerable, found #{val}")
      end
    end

    def get_loader_class(arg)
      GenericLoader
    end

  end

  # ================================================================
  class Base

    attr_reader :orm_class, :candidates, :conditions, :options

    def initialize(orm_class, candidates, conditions, options)
      @orm_class = orm_class
      @candidates = candidates
      @conditions = conditions
      @options = options
    end

    def update_or_insert
    end

    def within_transaction(&block)
      if options[:within_transaction]
        orm_class.transaction { yield }
      else
        yield
      end
    end
  end

  # ================================================================
  class GenericLoader < Base

    def update_or_insert
      within_transaction { update_or_insert_internal }
    end

    def update_or_insert_internal
      candidates.each {|candidate| update_or_insert_candidate(candidate) }
    end

    def update_or_insert_candidate(candidate)
      scope = get_scope(candidate)
      if scope.size > 0
        process_update(candidate, scope)
      else
        process_insert(candidate)
      end
    end

    def process_update(candidate, scope)
      update_action = options[:on_update]
      if update_action == :ignore
        tickle_rcov
      elsif update_action == :error
        raise UpdateError.new("expected no incumbents, found #{scope.count} incumbents")
      else
        update(candidate, scope)
      end
    end

    def process_insert(candidate)
      insert_action = options[:on_insert]
      if insert_action == :ignore
        tickle_rcov
      elsif insert_action == :error
        raise InsertError.new("expected an incumbent for #{candidate}")
      else
        insert(candidate)
      end
    end

    def get_scope(candidate)
      if (conditions == :all)
        orm_class.all(coerce_to_hash(candidate))
      elsif [nil, :none, []].member?(conditions)
        []
      else
        matcher = {}.tap do |hash| 
          conditions.each {|k| hash[k] = candidate[k]}
        end
        orm_class.all(matcher)
      end
    end

    def tickle_rcov
      a = 1
    end

    # DataMapper specific
    def coerce_to_hash(candidate)
      candidate.respond_to?(:attributes) ? candidate.attributes : candidate
    end

    def update(candidate, scope)
      if options[:on_update] == :all
        scope.update(coerce_to_hash(candidate))
      else
        update_fields = {}.tap do |hash|
          options[:on_update].each {|k| hash[k] = candidate[k]}
        end
        scope.update(update_fields)
      end
    end

    def insert(candidate)
      if options[:on_insert] == :all
        orm_class.create(coerce_to_hash(candidate))
      else
        insert_fields = {}.tap do |hash|
          options[:on_insert].each {|k| hash[k] = candidate[k]}
        end
        orm_class.create(insert_fields)
      end
    end

  end

end
