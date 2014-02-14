require 'cinch'
require 'ostruct'
require 'open-uri'
require 'json'

WUNDERGROUND_KEY = File.open('wunderground_key').read

module Cinch
  module Plugins
    class Wunderground

      include Cinch::Plugin

      match /weather (.+)/

      def initialize(*args)
        super
        @throttle = {req_minute: [], req_day: []}
      end

      def execute(msg, query)
        @throttle[:req_minute].reject!{ |r_m| r_m < Time.now - 60 }
        @throttle[:req_day].reject!{ |r_d| r_d < Time.now - 66400 }

        return msg.reply "give it a minute man" if @throttle[:req_minute].length >= 4
        return msg.reply "we've hit our 24hr limit" if @throttle[:req_day].length >= 20

        @throttle[:req_minute] << Time.now
        @throttle[:req_day] << Time.now

        # msg.reply "cool."
        location = geolookup(query)
        return msg.reply "weather station on fire." if location.nil?

        data = get_conditions(location)
        return msg.reply 'network on fire.' if data.nil?

        msg.reply(weather_summary(data))
      end

      def geolookup(zipcode)
        location = JSON.parse(open("http://api.wunderground.com/api/#{WUNDERGROUND_KEY}/geolookup/q/#{zipcode}.json").read)
        location['location']['l']
      rescue
        nil
      end

      def get_conditions(location)
        data          = JSON.parse(open("http://api.wunderground.com/api/#{WUNDERGROUND_KEY}/conditions#{location}.json").read)
        current       = data['current_observation']
        location_data = current['display_location']

        OpenStruct.new(
          location:          location_data['full'],
          weather:           current['weather'],
          temp:              current['temperature_string'],
          relative_humidity: current['relative_humidity'],
          feels_like:        current['feelslike_string']
        )
      rescue
        nil
      end

      def weather_summary(data)
        "#{data.location}: #{data.weather}, #{data.temp}.  Feels like #{data.feels_like}, man."
      rescue
        'i am on fire.'
      end
    end
  end
end