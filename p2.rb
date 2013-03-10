require_relative 'config/boot.rb'
trap("SIGINT") { debugger }
# Find utility bills
ServiceAccount.nightly_task
