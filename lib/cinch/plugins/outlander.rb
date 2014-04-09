require 'cinch'
require 'marky_markov'

module Cinch::Plugins
  class Outlander
    include Cinch::Plugin

    def initialize(*args)
      super
      @markov = MarkyMarkov::TemporaryDictionary.new(1)
      @markov.parse_file "data/BRANE"
      @timer = Time.now
    end

    set :prefix, //
    listen_to :channel

    set :help, <<-EOF
outlander
  He's just this guy, you know?
EOF

    def burp(m)

      is_full_sentence = rand(1..3).even?
      blurt = get_blurt(is_full_sentence)

      response = blurt.split(' ').each { |word|
        random_number = rand(0..100)
        if random_number > 95
          word.upcase!
        elsif random_number < 2
          word.downcase!
        end
      }.join(' ')

      # try to not end with dumb stuff
      response = response.gsub(/ (of|to|the|and|i|,|my|your)$/i,'')

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

    def get_blurt(is_full_sentence = false)
      blurt = nil
      success = false
      while !success && blurt.blank?
        begin
          blurt = is_full_sentence ? (@markov.generate_n_sentences 1) : (@markov.generate_n_words rand(6..25))
          success = true
        rescue ArgumentError => e
          puts e.to_s
        end
      end
      blurt
    end

  end
end