require_relative 'config/boot.rb'
trap("SIGINT") { debugger }
# Find weather observations concurent with the utility bills
DataMapper.logger.level = 3
WeatherStation.nightly_task
