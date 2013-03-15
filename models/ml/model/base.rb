module ML

  module Model

    class Base

      attr_reader :options, :converter

      DEFAULT_OPTIONS = {
        :type => :classification # :classification | :regression
      }

      # Create a Machine Learning Model. 
      #
      # +training_data+ is an Enumerable object where each element
      # represents one training example.  A training example contains
      # a +label+ and a set of +features+.
      # 
      # The +label_column+ argument names the field in each example
      # that is to be used as the label for training, accessed as in
      # example[label_column]
      #
      # The +feature_columns+ argument is an array of column names in
      # each example to be used for training, accessed as in
      # example[feature_column].

      def initialize(training_data, label_column, feature_columns, options = {})
        @options = DEFAULT_OPTIONS.merge(options)
        @converter = ML::Dataset::Converter.new(training_data, label_column, feature_columns)
      end
      
      def predict(testing_data, feature_columns = self.feature_columns(), options = {})
      end

      protected

    end
    
  end
  
end
