require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'yaml'

require_relative "lib/cinch/plugins/seen"
require_relative "lib/cinch/plugins/urban_dictionary"
require_relative "lib/cinch/plugins/outlander"
require_relative "lib/cinch/plugins/spew"
require_relative "lib/cinch/plugins/wunderground"
require_relative "lib/cinch/plugins/urls"

setup = YAML.load_file('config/setup.yaml')

bot = Cinch::Bot.new do
  configure do |c|
    c.server   = setup["server"]
    c.channels = setup["channels"]
    c.nick     = setup["nick"]
    c.user     = setup["user"]
    c.realname = setup["realname"]
    c.plugins.plugins = [
      Cinch::Plugins::Seen,
      Cinch::Plugins::UrbanDictionary,
      Cinch::Plugins::Outlander,
      Cinch::Plugins::Spew,
      Cinch::Plugins::Wunderground,
      Cinch::Plugins::Urls
    ]
  end
end

bot.start
