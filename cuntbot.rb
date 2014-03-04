require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'yaml'
require 'active_hash'

require_relative "lib/cinch/plugins/seen"
require_relative "lib/cinch/plugins/urban_dictionary"
require_relative "lib/cinch/plugins/outlander"
require_relative "lib/cinch/plugins/spew"
require_relative "lib/cinch/plugins/wunderground"
require_relative "lib/cinch/plugins/urls"
require_relative "lib/cinch/plugins/notes"
require_relative "lib/cinch/plugins/piga"
require_relative "lib/cinch/plugins/the_fucking_weather"

setup = YAML.load_file('config/setup.yaml')

@bot = Cinch::Bot.new do
  configure do |c|
    c.server   = setup["server"]
    c.channels = setup["channels"]
    c.nick     = setup["nick"]
    c.user     = setup["user"]
    c.realname = setup["realname"]
    c.plugins.plugins = [
      Cinch::Plugins::Outlander,
      Cinch::Plugins::Piga,
      Cinch::Plugins::Notes,
      Cinch::Plugins::Seen,
      Cinch::Plugins::Spew,
      Cinch::Plugins::TheFuckingWeather,
      Cinch::Plugins::UrbanDictionary,
      Cinch::Plugins::Urls,
      Cinch::Plugins::Wunderground
    ]
  end
end

@bot.start
