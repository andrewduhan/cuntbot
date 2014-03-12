require_relative "wunderground"

require 'cinch'

module Cinch::Plugins
  class Weather
    include Cinch::Plugin

    match /weather (.+)/

    def execute(msg, query)

      current_conditions = Wunderground::get_conditions(query)
      case current_conditions.status
      when "minlimit"
        return msg.reply "give it a minute man"
      when "daylimit"
        return msg.reply "we've hit our 24hr limit"
      when "nolocation"
        return msg.reply "weather station on fire."
      when "ambiguouslocation"
        return msg.reply "be more specific"
      when "nodata"
        return msg.reply "network on fire."
      when "ok"
        return msg.reply(weather_summary(current_conditions))
      else
        return msg.reply "i am on fire."
      end

    end

    def weather_summary(current_conditions)
      "#{current_conditions.display_location["full"]}: #{current_conditions.weather}, #{current_conditions.temperature_string}.  Feels like #{current_conditions.feelslike_string}."
    rescue
      'brain on fire.'
    end

  end
end