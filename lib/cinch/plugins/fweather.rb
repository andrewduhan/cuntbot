require_relative "wunderground"

require 'cinch'

module Cinch::Plugins
  class Fweather
    include Cinch::Plugin

    match /fweather (.+)/i

    set :help, <<-EOF
!fweather [fucking zip / fucking location]
  A fucking weather report.
EOF

    def initialize(*args)
      super
      @bylines = setup = YAML.load_file('data/fucking_weather.yaml')
    end

    def execute(msg, location)
      begin
        current_conditions = Wunderground::get_conditions(location)
        case current_conditions.status
        when "minlimit"
          return msg.reply "SLOW THE FUCK DOWN"
        when "daylimit"
          return msg.reply "WE'RE FUCKING DONE FOR THE DAY"
        when "nolocation"
          return msg.reply("I CAN'T FUCKING FIND " + location.upcase)
        when "ambiguouslocation"
          return msg.reply("THERE'S MORE THAN ONE FUCKING " + location.upcase)
        when "nodata"
          return msg.reply "THE WEATHER IS FUCKING BROKEN"
        when "ok"
          return msg.reply(fucking_summary(current_conditions))
        else
          return msg.reply "OW MY BRANE"
        end
      rescue
        return msg.reply "I'M FUCKING BROKEN"
      end
    end

    def fucking_summary(current_conditions)
      temp_f = current_conditions.temp_f.to_f
      display_temp = current_conditions.display_location["country"] == "US" ? current_conditions.temp_f.to_s + "F" : current_conditions.temp_c.to_s + "C"

      case
      when temp_f < 35
        general_condition = "freezing"
      when temp_f >= 35 && temp_f < 50
        general_condition = "cold"
      when temp_f >= 50 && temp_f < 65
        general_condition = "chilly"
      when temp_f >= 65 && temp_f < 80
        general_condition = "nice"
      when temp_f >= 80 && temp_f < 95
        general_condition = "warm"
      when temp_f >= 95
        general_condition = "hot"
      else
        general_condition = "derp"
      end

      byline = @bylines[general_condition][rand(0..@bylines[general_condition].length-1)]
      "#{display_temp} IN #{current_conditions.display_location["city"].upcase}?! IT'S FUCKING #{general_condition.upcase}! #{byline}"
    end

  end
end