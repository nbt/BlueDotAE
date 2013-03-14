require_relative 'config/boot.rb'
trap("SIGINT") { debugger }
# Get daily climate interquartile mean for stations near to Premise.first
Climate.daily_climate(Premises.first)
true

