require 'spec_helper'

describe "WeatherHistory Model" do
  let(:weather_history) { WeatherHistory.new }
  it 'can be created' do
    weather_history.should_not be_nil
  end
end
