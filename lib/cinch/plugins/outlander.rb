require 'cinch'
require 'open-uri'
require 'yaml'
require 'json'
require 'microsoft_translator'
require_relative '../../ms_translate_throttle'

module Cinch::Plugins
  class Outlander
    include Cinch::Plugin

    MS_TRANSLATE = YAML.load_file( 'config/ms_translate.yaml' ) rescue nil

    def initialize( *args )
      super

      @brain = {}
      File.foreach( 'data/BRANE' ) do |line|
        arr = line.scan( /[a-zA-Z0-9'’$%\]\[\)\()]+|[^a-zA-Z0-9'’$%\]\[\)\(]+/ ).select { |x| x.match( /\S/ ) }
        arr.each_with_index do |word, i|
          word = word.strip.downcase
          @brain[ word ] ||= []
          @brain[ word ].push( arr[i+1].strip.downcase ) if arr[i+1]
        end
      end
      @opening_words = @brain.reject{ |k,v| v.uniq.reject{ |c| !c.match(/[A-Za-z0-9]/) }.length <= 1 || !k.match(/[A-Za-z0-9]/) }.keys
      if MS_TRANSLATE
        @translator = MicrosoftTranslator::Client.new( MS_TRANSLATE["client_id"], MS_TRANSLATE["client_secret"] )
      end
      @timer = Time.now
    end

    set :prefix, //
    listen_to :channel

    set :help, <<-EOF
outlander
  He's just this guy, you know?
EOF

    def burp( m )
      start_time = Time.now.to_i
      blurt = get_blurt( m )
      elapsed_time = Time.now.to_i - start_time
      delay = rand(3..10)
      sleep (delay - elapsed_time) if (delay - elapsed_time) > 0
      m.reply blurt
    end

    def listen( m )
      if ( @timer + 60 < Time.now && rand(0..100) > 99 ) || ( m.message =~ /#{@bot.nick}/i )
        @timer = Time.now
        burp( m )
      end
    end

    def mutilate( blurt )
      if MsTranslateThrottle.instance.check
        langs = [
          "et","it","fa","sv","bs","fi","ja","pl","th","bg","fr","sw","pt","tr","ca","de","uk","zh","el","ro",
          "ht","ko","ru","hr","he","lv","sr","cy","cs","lt","da","sk","nl","hu","mt","sl","id","nb","es"
        ]
        lang1 = langs.sample
        lang2 = langs.reject{ |l| l == lang1 }.sample
        chars_translated = blurt.length
        new_blurt = @translator.translate( blurt, "en", lang1, "text/html" )
        chars_translated += new_blurt.length
        new_blurt = @translator.translate( new_blurt, lang1, lang2, "text/html" )
        chars_translated += new_blurt.length
        new_blurt = @translator.translate( new_blurt, lang2, "en", "text/html" )
        MsTranslateThrottle.instance.update( chars_translated )
        new_blurt.nil? || new_blurt.blank? ? blurt : new_blurt
      else
        blurt
      end
    end

    def get_blurt( m = nil )
      min_length = 10
      blurt = nil
      success = false
      word = ''

      while !success || blurt.nil? || blurt.blank?
        begin
          chain = []
          uppercase = rand(10) == 0
          while !word.match( /[A-Za-z0-9]/ )
            word = @opening_words.sample
          end
          chain.push( uppercase ? word.upcase : rand(4) == 0 ? word.capitalize : word )
          loop do
            if uppercase
              uppercase = rand(4) == 0
            else
              uppercase = rand(10) == 0
            end
            if @brain[ word ] && @brain[ word ].length > 0
              word = @brain[word].sample
              if word.match(/[\.\?\!]/)
                chain[ chain.length - 1 ] = chain[ chain.length - 1 ] + word if ( word == '.' && rand(2) == 0 ) || word != '.'
                break unless ( chain.length < min_length ) && ( rand( chain.length ) == 0 )
              else
                if word.match( /[\,\;]/ )
                  if chain.length > min_length
                    chain[ chain.length - 1 ] = chain[ chain.length - 1 ] + [ '.','','!','?' ].sample
                    break
                  else
                    chain[ chain.length - 1 ] = chain[ chain.length - 1 ] + word
                  end
                else
                  chain.push( uppercase ? word.upcase : word )
                end
              end
            else
              break
            end
          end
          blurt = uppercase ? chain.join(' ').upcase : chain.join(' ')
          blurt = blurt.gsub( / :/,":" ).gsub( / - /,"-" )
          success = true
        rescue ArgumentError => e
          puts e.to_s
        end
      end

      mutilate( blurt )
    end
  end
end