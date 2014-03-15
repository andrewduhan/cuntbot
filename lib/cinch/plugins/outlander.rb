require 'cinch'
require 'marky_markov'

module Cinch::Plugins
  class Outlander
    include Cinch::Plugin

    def initialize(*args)
      super
      @markov = MarkyMarkov::TemporaryDictionary.new
      @markov.parse_file "data/BRANE"
      @timer = Time.now
    end

    set :prefix, //
    listen_to :channel

    def burp(m)
      blurt = rand(1..2).even? ? (@markov.generate_n_words rand(10..50)) : (@markov.generate_n_sentences 1)
      response = blurt.split(' ').each { |word|
        random_number = rand(0..100)
        if random_number > 95
          word.upcase!
        elsif random_number < 2
          word.downcase!
        end
      }.join(' ')

      # try to not end with dumb stuff
      response = response.gsub(/ (of|to|the|i|,)$/i,'')

      if rand(0..2) > 0 # 1/3 chance of adding some punctuation
        punctuation = ['!','?'][rand(0..1)]
        response = response.gsub(/[,.;]$/, '')
        response += punctuation
      end
      sleep(rand(3..10))
      m.reply response
    end

    def listen(m)
      if (@timer + 60 < Time.now && rand(0..100) > 99) || (m.message =~ /#{@bot.nick}/i)
        @timer = Time.now
        burp(m)
      end
    end
  end
end