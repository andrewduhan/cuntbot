require 'cinch'

module Cinch::Plugins
  class Spew
    include Cinch::Plugin
    listen_to :channel

    match /spew (.+)/

    def listen(m)
      message = m.message.gsub(/outlander/, m.user.nick)
      File.write('learned_knowledge', message + "\n", File.size('learned_knowledge'), mode: 'a') if  m.message.length > 50
    end

    def execute(m, pattern)
      matches = []
      File.open('learned_knowledge') do |f|
        f.each_line do |line|
          matches << line if line.match(/#{pattern}/i)
        end
      end

      m.reply matches.length > 0 ? matches[rand(0..matches.length-1)] : "\"#{pattern}\" ain't in the logs!"
    end

  end
end