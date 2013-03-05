migration 10, :create_test_models do
  up do
    create_table :test_models do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :test_models
  end
end
