require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'yaml'
require 'active_hash'

require_relative "lib/cinch/plugins/note"
require_relative "lib/cinch/plugins/outlander"
require_relative "lib/cinch/plugins/piga"
require_relative "lib/cinch/plugins/plugin_list"
require_relative "lib/cinch/plugins/seen"
require_relative "lib/cinch/plugins/spew"
require_relative "lib/cinch/plugins/fweather"
require_relative "lib/cinch/plugins/udict"
require_relative "lib/cinch/plugins/urls"
require_relative "lib/cinch/plugins/weather"

setup = YAML.load_file('config/setup.yaml')

@bot = Cinch::Bot.new do
  configure do |c|
    c.server   = setup["server"]
    c.channels = setup["channels"]
    c.nick     = setup["nick"]
    c.user     = setup["user"]
    c.realname = setup["realname"]
    c.plugins.plugins = [
      Cinch::Plugins::Fweather,
      Cinch::Plugins::Note,
      Cinch::Plugins::Outlander,
      Cinch::Plugins::Piga,
      Cinch::Plugins::PluginList,
      Cinch::Plugins::Seen,
      Cinch::Plugins::Spew,
      Cinch::Plugins::Udict,
      Cinch::Plugins::Urls,
      Cinch::Plugins::Weather
    ]
  end
end

@bot.start
