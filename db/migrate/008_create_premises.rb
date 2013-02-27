migration 8, :create_premises do
  up do
    create_table :premises do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :premises
  end
end
