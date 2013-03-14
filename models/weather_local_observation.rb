require 'statistics'
require 'weather_observation_properties'

class WeatherLocalObservation
  include DataMapper::Resource

  # property <name>, <type>
  belongs_to :premises
  property :id, Serial
  module_eval(WEATHER_OBSERVATION_PROPERTIES)

  # Create or update WeatherLocalObservation records for a specific
  # premises.  
  #
  # This implements a (very) crude form of kriging: we simply take the
  # interquartile mean of each weather property among all the weather
  # stations in the vicinity of the premises.
  #
  # TODO: Break this out into a separate kriging module.
  #
  # Call this after
  # [1] weather_stations have been updated for premises
  # [2] each weather_station has called update_observations

  def self.update_local_observations(premises)
    vectors = create_vectors(premises)
    # vectors has the form:
    # {<date1> => {:temperature_min => [10, 13, 4, ...], :temperature_max => [] ...}, <date2> => {...}}
    means = interquartile_mean(vectors)
    # means has the form:
    # {<date1> => {:temperature_min => 12.3, :temperature_max => 16.2, ...}, <date2> => {...}}
    create_or_update_records(premises, means)
  end

  AVERAGABLE_FIELDS = WeatherObservation.properties.reject {|p| p.key? || p.index || p.name == :date}.map {|p| p.name}

  # {<date1> => {:temperature_min = [10, 13, 4, ...], :temperature_max = [] ...}, <date2> => {...}}
  #
  # TODO: add date range
  #
  # TODO: This is not fast.  There may be a faster way using a SQL query
  # that groups by date.
  #
  # F'rinstance: to create a list of how many observations each weather station has:
  # wsa = Premises.first.weather_stations.to_a
  # WeatherObservation.aggregate(:weather_station_id, :all.count, :weather_station => wsa)
  # => [[155, 790], [188, 790], [189, 790], [222, 790], [224, 629], ...]
  #
  # To create a list of how many weather stations report on each given date:
  # WeatherObservation.aggregate(:date, :all.count, :weather_station => wsa)
  # => [["2011-01-01", 25], ["2011-01-02", 25], ["2011-01-03", 22], 
  #     ["2011-01-04", 25], ["2011-01-05", 25], ["2011-01-06", 23], ...]
  # 
  # NB: nearly none of the time goes into the query.  Almost all of the time
  # is within th wos.each ... block
  #
  def self.create_vectors(premises)
    fields = AVERAGABLE_FIELDS

    weather_stations = premises.weather_stations.to_a
    {}.tap do |hash|
      weather_stations.each do |weather_station|
        wos = WeatherObservation.all(:weather_station => weather_station)
        # Most of the time is spent in wos.each, presumably reifying
        # the observations.
        wos.each do |observation|
          date = observation[:date]
          bucket = (hash[date] ||= {})
          fields.each do |field|
            # TODO: the '|| 0.0' is because the precipitation field sometimes has
            # nil values.  Find out the cause and fix it.
            (bucket[field] ||= []) << (observation[field] || 0.0)
          end
        end
      end
    end
  end

  def self.interquartile_mean(vectors)
    {}.tap do |hash|
      vectors.each_pair do |date, fields|
        hash[date] = interquartile_mean_day(fields)
      end
    end
  end

  # fields is 
  #    {:temperature_min => [10, 13, 4, ...], :temperature_max => [12, 18, 6] ...}
  # Return a hash where each vector of values is replaced with its interquartile mean, e.g.
  #    {:temperature_min => 12.3, :temperature_max => 16.2, ...}
  def self.interquartile_mean_day(fields)
    {}.tap do |hash|
      fields.each_pair do |field_name, vector|
        hash[field_name] = Statistics.interquartile_mean(vector)
      end
    end
  end

  # means has the form:
  # {<date1> => {:temperature_min => 12.3, :temperature_max => 16.2, ...}, <date2> => {...}}
  def self.create_or_update_records(premises, means)
    means.each_pair do |date, parameters|
      WeatherLocalObservation.first_or_create({:premises => premises, :date => date}, parameters)
    end
  end

end
