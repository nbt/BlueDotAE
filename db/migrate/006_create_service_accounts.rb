migration 6, :create_service_accounts do
  up do
    create_table :service_accounts do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :service_accounts
  end
end
