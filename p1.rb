require_relative 'config/boot.rb'
trap("SIGINT") { debugger }
# Find local weather stations
Premises.nightly_task
