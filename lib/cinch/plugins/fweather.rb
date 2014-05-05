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

      # annoy josh by sort of scaling summary to the latitude
      temp_scaler = 560.0/653.0

      scaled_temp = temp_f + (( current_conditions.display_location["latitude"].to_f.abs - 15 ) * temp_scaler ) - 10

      case
      when scaled_temp < 15
        general_condition = "seriously fucking freezing"
      when scaled_temp >= 0 && scaled_temp < 32
        general_condition = "freezing"
      when scaled_temp >= 32 && scaled_temp < 50
        general_condition = "cold"
      when scaled_temp >= 50 && scaled_temp < 65
        general_condition = "chilly"
      when scaled_temp >= 65 && scaled_temp < 80
        general_condition = "nice"
      when scaled_temp >= 80 && scaled_temp < 95
        general_condition = "warm"
      when scaled_temp >= 95
        general_condition = "hot"
      else
        general_condition = "derp"
      end

      sub_condition = ""
      {
        "drizzle" => "drizzling", "rain" => "rainy", "snow" => "snowing", "ice" => "icy", "hail" => "hailing", "mist" => "misty", "fog" => "foggy",
        "smoke" => "smoky", "volcanic ash" => "... fucking ashy?", "sand" => "sandy", "haze" => "hazy", "spray" => "spraying", "dust" => "dusty",
        "thunder" => "thundering", "overcast" => "overcast", "mostly cloudy" => "cloudy", "squalls" => "blowing", "funnel cloud" => "there is a fucking tornado"
      }.each do |condition, description|
        if current_conditions.weather.match(/#{condition}/i)
          sub_condition += " and #{description}."
        end
      end

      wind_mph = current_conditions.wind_mph
      case
      when wind_mph > 15 && wind_mph < 25
        sub_condition += " and windy."
      when wind_mph >= 25 && wind_mph < 40
        sub_condition += " and fucking windy."
      when wind_mph >= 40 && wind_mph < 70
        sub_condition += " and fucking violently windy."
      when wind_mph >= 70 && wind_mph < 100
        sub_condition += " and there is probably a fucking hurricane."
      when wind_mph >= 100
        sub_condition += " and there is a fucking tornado."
      end

      byline = @bylines[general_condition][rand(0..@bylines[general_condition].length-1)]

      "#{display_temp} IN #{current_conditions.display_location["city"].upcase}?! IT'S FUCKING #{general_condition.upcase}!#{sub_condition.upcase} #{byline}"
    end

  end
end