require 'cinch'
require 'twss'

module Cinch::Plugins
  class Twss
    include Cinch::Plugin
    listen_to :channel

    set :help, <<-EOF
"help" is not what she said.
EOF

    def listen(m)
      unless m.message.match(/^!/) || m.message.match(/outlander/i)
        if TWSS(m.message) && rand(8) == 0
          sleep(rand(2..4))
          m.reply "that's what she said" + ['','','','.','!','?'].sample
        end
      end
    end

  end
end