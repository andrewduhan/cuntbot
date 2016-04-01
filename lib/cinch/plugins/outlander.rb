require 'cinch'
# require 'marky_markov'

module Cinch::Plugins
  class Outlander
    include Cinch::Plugin

    def initialize(*args)
      super

      @brain = {}
      File.foreach('data/BRANE') do |line|
        arr = line.scan(/[a-zA-Z0-9'’$%\]\[\)\()]+|[^a-zA-Z0-9'’$%\]\[\)\(]+/).select { |x| x.match( /\S/ ) }
        arr.each_with_index do |word, i|
          word = word.strip.downcase
          @brain[word] ||= []
          @brain[word].push(arr[i+1].strip.downcase) if arr[i+1]
        end
      end
      @timer = Time.now
    end

    set :prefix, //
    listen_to :channel

    set :help, <<-EOF
outlander
  He's just this guy, you know?
EOF

    def burp(m)
      blurt = get_blurt
      sleep(rand(3..10))
      m.reply blurt
    end

    def listen(m)
      if (@timer + 60 < Time.now && rand(0..100) > 99) || (m.message =~ /#{@bot.nick}/i)
        @timer = Time.now
        burp(m)
      end
    end

    def get_blurt
      min_length = 10
      blurt = nil
      success = false
      while !success && blurt.blank?
        begin
          chain = []
          uppercase = rand(10) == 0
          word = ''
          while !word.match(/[A-Za-z0-9]/)
            word = @brain.keys.sample
          end
          chain.push( uppercase ? word.upcase : rand(4) == 0 ? word.capitalize : word )
          loop do
            if uppercase
              uppercase = rand(4) == 0
            else
              uppercase = rand(10) == 0
            end
            if @brain[word] && @brain[word].length > 0
              word = @brain[word].sample
              if word.match(/[\.\?\!]/)
                chain[chain.length - 1] = chain[chain.length - 1] + word if (word == '.' && rand(2) == 0) || word != '.'
                break unless (chain.length < min_length) && (rand(chain.length) == 0)
              else
                if word.match(/[\,\;]/)
                  if chain.length > min_length
                    chain[chain.length - 1] = chain[chain.length - 1] + ['.','','!','?'].sample
                    break
                  else
                    chain[chain.length - 1] = chain[chain.length - 1] + word
                  end
                else
                  chain.push(uppercase ? word.upcase : word)
                end
              end
            else
              break
            end
          end
          blurt = uppercase ? chain.join(' ').upcase : chain.join(' ')
          blurt = blurt.gsub(/ :/,":" ).gsub(/ - /,"-" )
          success = true
        rescue ArgumentError => e
          puts e.to_s
        end
      end
      blurt
    end

  end
end