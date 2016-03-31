require 'cinch'

module Cinch::Plugins
  class Spew
    include Cinch::Plugin
    listen_to :channel

    match /spew (.+)/i

    set :help, <<-EOF
!spew [word or phrase or regex]
  Find a random line in the chatlog.  Accepts simple regex:  Use .* as a wildcard and \\ to escape special characters such as ./!^$
EOF

    SPEWFILE = 'data/spewfile'

    def listen(m)
      unless m.message.match(/^!/) || m.user.nick == "bubbles"
        message = m.message.gsub(/outlander/, m.user.nick)
        File.write(SPEWFILE, message + "\n", File.size(SPEWFILE), mode: 'a') if  m.message.length > 30
      end
    end

    def execute(m, pattern)
      safe_pattern = Regexp.compile(pattern).to_s.match(/:(.*)\)/)[1]
      matches = File.open(SPEWFILE) { |f| f.grep(/#{safe_pattern}/i) }
      m.reply matches.length > 0 ? matches.sample : "\"#{pattern}\" ain't in the logs!"
    end

  end
end