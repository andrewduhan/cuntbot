require 'cinch'

module Cinch::Plugins
  class Spew
    include Cinch::Plugin
    listen_to :channel

    match /spew (.+)/

    DATA_FILE = 'data/learned_knowledge'

    def listen(m)
      unless m.message.match(/^!/)
        message = m.message.gsub(/outlander/, m.user.nick)
        File.write(DATA_FILE, message + "\n", File.size(DATA_FILE), mode: 'a') if  m.message.length > 50
      end
    end

    def execute(m, pattern)
      safe_pattern = Regexp.compile(pattern).to_s.match(/:(.*)\)/)[1]
      matches = `grep -i "#{safe_pattern}" data/learned_knowledge`.split(/\n/)
      m.reply matches.length > 0 ? matches[rand(0..matches.length-1)] : "\"#{pattern}\" ain't in the logs!"
    end

  end
end