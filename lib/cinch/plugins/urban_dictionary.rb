require 'cinch'

module Cinch::Plugins
  class UrbanDictionary
    include Cinch::Plugin

    match /udict (.+)/i
    def lookup(word)
      url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(word)}"
      CGI.unescape_html Nokogiri::HTML(open(url)).at("div.meaning").text.gsub(/\s+/, ' ') rescue nil
    end

    def execute(m, word)
      m.reply (lookup(word) || "no match for #{word}")
    end
  end
end