require 'cinch'

module Cinch::Plugins
  class TheFuckingWeather
    include Cinch::Plugin

    match /fweather (.+)/
    def fucking_look_it_up(search)
      url = "http://www.thefuckingweather.com/?where=#{CGI.escape(search)}"
      page = Nokogiri::HTML(open(url))
      if page
        begin
          if page.at("#locationDisplaySpan") && page.at("#locationDisplaySpan").text.length > 1
            location = page.at("#locationDisplaySpan").text.strip.upcase
            main_phrase = page.at('.remarkContainer .remark').text.strip
            sub_phrase = page.at('.content .flavor').text.strip
            response = location + "?! " + main_phrase + "            " + sub_phrase
          else
            response = "I CAN'T FUCKING FIND " + search.upcase
          end
        rescue
        end
      end
      response ||= "SOMETHING'S FUCKING BROKEN"
    end

    def execute(m, word)
      m.reply fucking_look_it_up(word)
    end
  end
end