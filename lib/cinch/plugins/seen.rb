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
    match /seen (.+)/

    def initialize(*args)
      super
      @users = {}
    end

    def listen(m)
      @users[m.user.nick] = SeenStruct.new(m.user, m.message, Time.now)
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
  end
end