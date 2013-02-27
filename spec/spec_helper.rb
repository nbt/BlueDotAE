PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  DataMapper.auto_migrate!
end

def app
  ##
  # You can handle all padrino applications using instead:
  #   Padrino.application
  BlueDotAe.tap { |app|  }
end

def reset_db
  DataMapper::Model.descendants.each {|d| d.destroy!}
end
