module ML
  module Dataset
    
    # Dataset: a collection of Examples
    # Example: For training, a Label and a set of Features.
    #          For testing, the Label wll be nil
    # Label: the category (for categorization) or value (for regression)
    #        produced by the example
    # Feature: One facet of the input state for the Example
    #
    class Dataset < Array
    end
    
  end
end
