module ML

  module Model

    class LIBSVM < Base

      # NOTE: for parameter selection without doing exhaustive grid search, see:
      # http://www.ece.umn.edu/users/cherkass/N2002-SI-SVM-13-whole.pdf

      def initialize(training_dataset, response_column, feature_columns, options = {})
        super
      end
      
      def predict(testing_dataset, feature_columns = self.feature_columns(), options = {})
      end

  end

end
