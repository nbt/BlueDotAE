module ML

  module Model

    class LIBSVM < Base

      Feature = Struct.new(:name, :accesor)

      def initialize(training_dataset, label_column, feature_columns, options = {})
        super
      end
      
      def predict(testing_dataset, feature_columns = self.feature_columns(), options = {})
      end

  end

end
