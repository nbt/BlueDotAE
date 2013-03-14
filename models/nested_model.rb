SHARED_FIELDS=<<EOF
  property :id, Serial
  property :shared_field1, String
  property :shared_field2, String
EOF

class Model1
  include DataMapper::Resource
  module_eval(SHARED_FIELDS)
  belongs_to :premises
end

class Model2
  include DataMapper::Resource
  module_eval(SHARED_FIELDS)
  belongs_to :weather_station
end
