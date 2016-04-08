require 'singleton'
require 'yaml'

class MsTranslateThrottle
  include Singleton

  MAX_CHARS_PER_MONTH = ( 2000000 - 10000 )

  def initialize
    @throttle_file = 'data/ms_translate_throttle.yml'
    @throttle_data = YAML.load_file( @throttle_file ) rescue []
  end

  def check
    @throttle_data[ current_month ].to_i < MAX_CHARS_PER_MONTH
  end

  def current_count
    @throttle_data[ current_month ].to_i
  end

  def update( addl_char_count )
    count = @throttle_data[ current_month ].to_i
    @throttle_data[ current_month ] = count + addl_char_count
    save_file
    true
  end

  def current_month
    Date.today.strftime( "%Y%m" )
  end

  def save_file
    File.open( @throttle_file, 'w' ) { |f|
      f.write( @throttle_data.to_yaml )
    }
  end

end