module Cinch::Plugins
  class PluginList
    include Cinch::Plugin
    match /help(.*)?/i

    def initialize(*args)
      super
      @plugins = bot.config.plugins.plugins.map{|plugin| plugin.to_s.split("::").last.downcase}
    end

    def execute(msg, qry)
      unless @plugins.include?(qry.strip) # let the built-in help sytem handle qry is blank or not a valid plugin
        @plugins.reject!{|p| p == 'outlander' || p == 'pluginlist'}
        msg.reply("i can " + @plugins.sort.join(", ") + ". you can !help [plugin]")
      end
    end
  end
end