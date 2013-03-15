module ML

  module Dataset
    
    class Converter

      attr_reader :training_data, :label_column, :feature_columns

      def initialize(training_data, label_column, feature_columns)
        @training_data = training_data
        @label_column = label_column
        @feature_columns = feature_columns
      end

      def create_dataset(source_data, is_testing = false)
        Dataset.new(source_data.map {|source_example| 
                      generate_example(source_example, is_testing)})
      end

      def headers
        [label_column.to_s] + feature_accessors.map {|feature_accessor|
          feature_accessor.name
        }
      end

      protected

      def generate_example(source_example, is_testing)
        Example.new(generate_label(source_example, is_testing), generate_features(source_example))
      end

      def generate_label(source_example, is_testing)
        {label_column.to_s => is_testing ? nil : source_example[label_column]}
      end

      def generate_features(source_example)
        {}.tap do |hash|
          feature_accessors.each do |feature_accessor| 
            hash[feature_accessor.name] = feature_accessor.proc.call(source_example)
          end
        end
      end

      def feature_accessors
        @feature_accessors ||= generate_feature_accessors
      end

      def generate_feature_accessors
        feature_columns.map do |feature_column|
          generate_feature_accessor(feature_column)
        end.flatten
      end

      class FeatureAccessor < Struct.new(:name, :proc) ; end

      def generate_feature_accessor(feature_column)
        categories = get_categories(feature_column)
        if categories
          categories.map do |category|
            FeatureAccessor.new("#{feature_column}=#{category}",
                                lambda {|example| (example[feature_column] == category) ? 1.0 : 0.0 })
          end
        else
          FeatureAccessor.new(feature_column.to_s, lambda {|example| example[feature_column]})
        end
      end

      # If all the elements of the named column in the source_dataset
      # are numeric (or blank), return nil, indicating this column is
      # not subject to catetory expansion.  Otherwise return a set of
      # each distinct value found in the column.  This will be used to
      # create multiple binary-valued columns.
      def get_categories(feature_column)
        column_values = training_data.map {|example| example[feature_column]}
        if column_values.all? {|cell| cell.kind_of?(Numeric) || cell.nil? || cell==''}
          nil
        else
          column_values.to_set
        end
      end

    end
    
  end

end
