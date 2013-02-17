migration 5, :create_meter_readings do
  up do
    create_table :meter_readings do
      column :id, Integer, :serial => true
      column :service_account, Reference
      column :date, DateTime
      column :cost, Float
      column :quantity, Float
    end
  end

  down do
    drop_table :meter_readings
  end
end
