# Improved support for DataMapper in FactoryGirl

=begin
# Nice try, but this breaks Account passwords
class CreateForDataMapper
  def initialize
    @default_strategy = FactoryGirl::Strategy::Create.new
  end

  delegate :association, to: :@default_strategy

  def result(evaluation)
    evaluation.singleton_class.send :define_method, :create do |instance|
      instance.save || raise(instance.errors.send(:errors).map{|attr,errors| "- #{attr}: #{errors}" }.join("\n"))
    end

    @default_strategy.result(evaluation)
  end
end

FactoryGirl.register_strategy(:create, CreateForDataMapper)
=end

FactoryGirl.define do

  factory :account do
    name
    email
    role "admin"
    password "password"
  end

  factory :client do
    name
  end

  factory :meter_reading do
    service_account
  end

  factory :premises do
    client
    raw_address { generate(:address) }
  end    
  
  factory :service_account do
    premises
    service_provider_class "SDGE"
  end

  factory :premises_weather_station_adjacency do
    premises
    weather_station
  end

  factory :test_model do
  end

  factory :weather_station do
    sequence(:callsign) {|n| sprintf("K%03d", n) }
    station_type "pws"
  end

  factory :weather_observation do
    weather_station
  end
    
end
