migration 7, :create_clients do
  up do
    create_table :clients do
      column :id, Integer, :serial => true
      column :name, String, :length => 255
    end
  end

  down do
    drop_table :clients
  end
end
