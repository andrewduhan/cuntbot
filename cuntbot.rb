require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'

require_relative "lib/cinch/plugins/seen"
require_relative "lib/cinch/plugins/urban_dictionary"
require_relative "lib/cinch/plugins/outlander"
require_relative "lib/cinch/plugins/spew"
require_relative "lib/cinch/plugins/wunderground"
require_relative "lib/cinch/plugins/urls"

bot = Cinch::Bot.new do
  configure do |c|
    c.server   = "irc_server.com"
    c.channels = ["#channel"]
    c.nick     = "outlander"
    c.user     = "cuntbot"
    c.realname = "cuntbot"
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
