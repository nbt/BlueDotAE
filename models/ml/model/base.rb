module ML

  module Model

    class Base

      # NOTE: 
      # For datasets for testing (classification and regression) see:
      # http://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/
      # http://archive.ics.uci.edu/ml/

      attr_reader :options, :converter

      DEFAULT_OPTIONS = {
        :type => :classification # :classification | :regression
      }

      # Create a Machine Learning Model. 
      #
      # +training_data+ is an Enumerable object where each element
      # represents one training instance.  A training instance contains
      # a +response+ and a set of +features+.
      # 
      # The +response_column+ argument names the field in each instance
      # that is to be used as the response for training, accessed as in
      # instance[response_column]
      #
      # The +feature_columns+ argument is an array of column names in
      # each instance to be used for training, accessed as in
      # instance[feature_column].

      def initialize(training_data, response_column, feature_columns, options = {})
        @options = DEFAULT_OPTIONS.merge(options)
        @converter = ML::Dataset::Converter.new(training_data, response_column, feature_columns)
      end
      
      def predict(testing_data, feature_columns = self.feature_columns(), options = {})
      end

      protected

    end
    
  end
  
end
