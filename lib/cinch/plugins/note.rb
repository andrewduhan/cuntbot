require 'cinch'

module Cinch::Plugins
  class Note
    class NoteStruct < Struct.new(:sender, :recipient, :note, :time)
      def to_s
        minutes = (Time.now - time) / 60
        hrs, mins = minutes.divmod(60)
        time_string = if hrs == 0
          "#{mins.to_i}m"
        elsif 24 > hrs && hrs > 0
          "#{hrs.to_i}h #{mins.to_i}m"
        else
          days, hrs = hrs.divmod(24)
          "#{days.to_i}d #{hrs.to_i}h"
        end
        "note for you, #{recipient}! #{time_string}: <#{sender}> #{note}"
      end
    end

    include Cinch::Plugin
    listen_to :join
    listen_to :channel
    match /note (.+)/

    def initialize(*args)
      super
      @users = {}
    end

    def listen(m)
      if @users[m.user.nick] && @users[m.user.nick].length > 0
        @users[m.user.nick].each do |note|
          m.reply(note.to_s)
        end
        @users.delete(m.user.nick)
      end
    end

    def execute(m, note)
      exploded_message = note.split(' ')
      recipient = exploded_message.shift
      @users[recipient] = [] unless @users[recipient]
      @users[recipient] << NoteStruct.new(m.user, recipient, exploded_message.join(' '), Time.now)
    end

  end
end