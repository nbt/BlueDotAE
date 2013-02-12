PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
require 'vcr_setup'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  $stderr.puts("=== in spec helper, Padrino.env = #{Padrino.env}")
  user = ENV['POSTGRESQL_USERNAME'] || 'root'
  pass = ENV['POSTGRESQL_PASSWORD'] || ''
  DataMapper.setup(:default, "postgres://#{user}:#{pass}@localhost/blue_dot_ae_test")
  DataMapper.finalize
  DataMapper::Model.descendants.entries.each {|model| model.auto_migrate! }
end

def app
  ##
  # You can handle all padrino applications using instead:
  #   Padrino.application
  BlueDotAe.tap { |app|  }
end
