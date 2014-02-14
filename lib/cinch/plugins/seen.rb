require 'cinch'

module Cinch::Plugins
  class Seen
    class SeenStruct < Struct.new(:who, :what, :time)
      def to_s
        "[#{time.asctime}] #{who} was last seen saying #{what}"
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
        m.reply "That's me!"
      elsif nick == m.user.nick
        m.reply "That's you!"
      elsif @users.key?(nick)
        m.reply @users[nick].to_s
      else
        m.reply "I ain't seen #{nick}"
      end
    end
  end
end