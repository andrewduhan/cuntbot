require 'cinch'
require 'ostruct'
require 'open-uri'
require 'json'
require 'yaml'
require_relative '../../wunder_throttle'

WUNDERGROUND_KEY = YAML.load_file('config/wunderground.yaml')["key"]

module Wunderground

  def self.get_conditions(location)

    output = OpenStruct.new()
    output[:status] = WunderThrottle.instance.check
    # begin
      if output[:status]  == 'ok'
        location = geolookup(location)
        output[:status] = 'nolocation' if location.nil?
        output[:status] = 'ambiguouslocation' if location == 'ambiguouslocation'
      end

      if output[:status]  == 'ok'
        data = JSON.parse(open("http://api.wunderground.com/api/#{WUNDERGROUND_KEY}/conditions#{location}.json").read)
        puts data.to_s
        output[:status] = 'nodata' if data.nil?
      end

      if output[:status]  == 'ok' && data
        # data
        current       = data['current_observation']
        location_data = current['display_location']
        output[:location]           = location_data['full']
        output[:country]            = location_data['country']
        output[:state]              = location_data['state']
        output[:city]               = location_data['city']
        output[:weather]            = current['weather']
        output[:temperature_string] = current['temperature_string']
        output[:temp_f]             = current['temp_f']
        output[:temp_c]             = current['temp_c']
        output[:wind_mph]           = current['wind_mph']
        output[:wind_gust_mph]      = current['wind_gust_mph']
        output[:relative_humidity]  = current['relative_humidity']
        output[:feelslike_string]   = current['feelslike_string']
      end
    # rescue
      # output[:status] = 'error'
    # end

    output
  end

  def self.geolookup(location)
    puts "fetching " + URI.encode("http://api.wunderground.com/api/#{WUNDERGROUND_KEY}/geolookup/q/#{location}.json").to_s
    location = JSON.parse(open(URI.encode("http://api.wunderground.com/api/#{WUNDERGROUND_KEY}/geolookup/q/#{location}.json")).read)
    if location['response']['results']  # returned more than one location
      'ambiguouslocation'
    else
      location['location']['l']
    end
  rescue
    nil
  end

end