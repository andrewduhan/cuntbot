require 'cinch'
require 'marky_markov'

module Cinch::Plugins
  class Outlander
    include Cinch::Plugin

    def initialize(*args)
      super
      @markov = MarkyMarkov::TemporaryDictionary.new
      @markov.parse_file "data/knowledge"
      @timer = Time.now
    end

    set :prefix, //
    listen_to :channel

    def burp(m)
      message_word_length = m.message.scan(' ').length
      max_reply_length = message_word_length > 40 ? 40 : message_word_length
      max_reply_length = 10 if max_reply_length < 10
      max_reply_length = max_reply_length * 2
      response = (@markov.generate_n_words rand(10..max_reply_length)).split(' ').each { |word|
        random_number = rand(0..100)
        if random_number > 80
          word.upcase!
        elsif random_number < 20
          word.downcase!
        end
      }.join(' ')
      sleep(rand(2..6))
      m.reply response
    end

    def listen(m)
      if (@timer + 60 < Time.now && rand(0..100) > 99) || (m.message =~ /#{@bot.nick}/)
        @timer = Time.now
        burp(m)
      end
    end
  end
end