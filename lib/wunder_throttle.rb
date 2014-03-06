require 'singleton'

class WunderThrottle
  include Singleton

  def initialize
    @throttle = {req_minute: [], req_day: []}
  end

  def check
    @throttle[:req_minute].reject!{ |r_m| r_m < Time.now - 60 }
    @throttle[:req_day].reject!{ |r_d| r_d < Time.now - 66400 }

    output = if @throttle[:req_minute].length >= 4
      'minlimit'
    elsif @throttle[:req_day].length >= 20
      'daylimit'
    else
      'ok'
    end

    if output == 'ok'
      @throttle[:req_minute] << Time.now
      @throttle[:req_day] << Time.now
    end

    output
  end

end