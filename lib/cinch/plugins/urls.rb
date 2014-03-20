require 'cinch'

module Cinch::Plugins
  class Urls
    class UrlStruct < Struct.new(:who, :message, :time)
      def to_s
        "[#{time.strftime('%R')}] #{who}: #{message}"
      end
    end

    include Cinch::Plugin
    listen_to :channel
    match /urls ?(.+)?/i

    set :help, <<-EOF
!urls [number]
  Show the last [number] urls (max 10)
EOF

    def initialize(*args)
      super
      @urls = []
    end

    def listen(m)
      @urls.unshift(UrlStruct.new(m.user, m.message, Time.now)) if m.message.match(/https?:\/\//)
      @urls.pop if @urls.length > 10
    end

    def execute(m, url_count = 3)
      if @urls.length == 0
        m.reply "i got nothing"
      else
        url_count = url_count.to_i
        url_count = @urls.length if url_count > @urls.length
        url_count = 10 if url_count > 10
        url_count = 1 if url_count < 1
        reply_urls = @urls[0..url_count-1]
        reply_urls.each do | url |
          m.reply url.to_s
        end
      end
    end
  end
end