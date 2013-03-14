# The following properties are shared between WeatherObservation and
# WeatherSummary models.

WEATHER_OBSERVATION_PROPERTIES=<<EOF
  property :date, DateTime
  property :temperature_max_f, Float
  property :temperature_avg_f, Float
  property :temperature_min_f, Float
  property :dewpoint_max_f, Float
  property :dewpoint_avg_f, Float
  property :dewpoint_min_f, Float
  property :humidity_max, Float
  property :humidity_avg, Float
  property :humidity_min, Float
  property :pressure_max_in, Float
  property :pressure_avg_in, Float
  property :pressure_min_in, Float
  property :windspeed_max_mph, Float
  property :windspeed_avg_mph, Float
  property :precipitation_in, Float
EOF
