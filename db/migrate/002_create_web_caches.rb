migration 2, :create_web_caches do
  up do
    create_table :web_caches do
      column :id, Integer, :serial => true
      column :serialized_key, Text
      column :serialized_value, Text
      column :created_at, Timestamp
      column :updated_at, Timestamp
    end
  end

  down do
    drop_table :web_caches
  end
end
