require 'cinch'
require 'marky_markov'

module Cinch::Plugins
  class Outlander
    include Cinch::Plugin

    def initialize(*args)
      super
      @markov = MarkyMarkov::TemporaryDictionary.new
      @markov.parse_file "knowledge"
      @timer = Time.now
    end

    set :prefix, //
    match /outlander/
    listen_to :channel

    def execute(m)
      message_word_length = m.message.scan(' ').length
      max_reply_length = message_word_length > 40 ? 40 : message_word_length
      max_reply_length = 10 if max_reply_length < 10
      max_reply_length = max_reply_length * 2
      response = @markov.generate_n_words rand(10..max_reply_length)
      sleep(rand(2..6))
      m.reply response
    end

    def listen(m)
      if @timer + 60 < Time.now && rand(0..100) > 99
        @timer = Time.now
        execute(m)
      end
    end
  end
end