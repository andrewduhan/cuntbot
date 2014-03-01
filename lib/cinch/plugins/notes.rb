require 'cinch'

class Note < ActiveYaml::Base
  set_root_path "data"
  set_filename "notes"

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
    "note for you, #{recipient}! [#{time_string}] <#{sender}> #{note}"
  end

  def save(*args)
    super
    File.open(Note.full_path, 'w') do |file|
      file.write(Note.all.map(&:attributes).to_yaml)
    end
  end

  def deliver
    self.delivered = true
    self.save
    # Note.load_file
  end
end

module Cinch::Plugins

  class Notes
    include Cinch::Plugin
    listen_to :join
    listen_to :channel
    match /note (.+)/

    def listen(m)
      notes = Note.find_all_by_recipient_and_delivered(m.user.nick, false)
      if notes.length > 0
        notes.each do |note|
          m.reply(note.to_s)
          note.deliver
        end
      end
    end

    def execute(m, note)
      exploded_message = note.split(' ')
      recipient = exploded_message.shift
      if recipient == m.user.nick
        m.reply ('you try to talk to yourself, but find you already know what you are going to say.')
      elsif recipient == @bot.nick
        m.reply ("...it's like I'm not even here.")
      else
        Note.create(sender: m.user.nick, recipient: recipient, note: exploded_message.join(' '), time: Time.now, delivered: false)
        m.reply('got it.')
      end
    end

  end
end