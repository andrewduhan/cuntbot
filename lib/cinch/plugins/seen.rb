require 'cinch'

module Cinch::Plugins
  class Seen
    class SeenStruct < Struct.new(:who, :what, :time)
      def to_s
        minutes = (Time.now - time) / 60
        hrs, mins = minutes.divmod(60)
        time_string = hrs == 0 ? "#{mins.to_i} mins ago" : "#{hrs.to_i} hours and #{mins.to_i} mins ago"
        "#{who} was last seen #{time_string} saying \"#{what}\""
      end
    end

    include Cinch::Plugin
    listen_to :channel
    match /seen (.+)/i

    set :help, <<-EOF
!seen [nick]
  When a nick was last seen and what they were saying or doing
EOF

    def initialize(*args)
      super
      @users = {}
      @seen_file = 'data/seen.yml'
      load_file
    end

    def listen(m)
      @users[m.user.nick] = SeenStruct.new(m.user.nick, m.message, Time.now)
      save_file
    end

    def execute(m, nick)
      if nick == @bot.nick
        m.reply "that's me!"
      elsif nick == m.user.nick
        m.reply "that's you!"
      elsif @users.key?(nick)
        m.reply @users[nick].to_s
      else
        m.reply "I ain't seen #{nick}!"
      end
    end

    def save_file
      File.open(@seen_file, 'w') { |f|
        f.write(@users.values.map{|v| v.to_h}.to_yaml)
      }
    end

    def load_file
      data = YAML.load_file(@seen_file) || []
      data.each do |d|
        @users[d[:who]] = SeenStruct.new(d[:who], d[:what], d[:time])
      end
    end
  end
end