require 'cinch'

module Cinch::Plugins
  class Help
    include Cinch::Plugin

    match /help(.*)/i

    set :help, <<-EOF
!help <plugin>
  Show help for a plugin.
EOF

    def execute(msg, query)
      query = query.strip.downcase
      response = ""

      if query.empty?
        response << "plugins: " + bot.config.plugins.plugins.map{|plugin| plugin.to_s.split("::").last.downcase}.join(", ")
        response << "\nyou can also type !help [plugin]"

      # elsif plugin = @help.keys.find{|plugin| format_plugin_name(plugin) == query}
      #   @help[plugin].keys.sort.each do |command|
      #     debugger
      #     response << format_command(command, @help[plugin][command], plugin)
      #   end

      else
        response << "never heard of '#{query}'."
      end

      response << "something went wrong" if response.empty?
      msg.reply(response)
    end

    private

    def format_command(command, explanation, plugin)
      debugger
      explanation.lines.map(&:strip).join(" ").chars.each_slice(80).map(&:join).join("\n")
    end

    # assuming plugin classes == plugin commands. If I was smarterer I'd grab plugin commands automagically
    def format_plugin_name(plugin)
      plugin.to_s.split("::").last.downcase
    end

  end
end