require 'log4r'
require 'singleton'
# The module has a classes and a class method to intialize a logger and to specify formatting style using log4r library.
module PayPalSDKUtils
   def mask_data(data)
      data1=data.sub(/PWD=[^&]*\&/,'PWD=XXXXXX&')
      data2=data1.sub(/acct=[^&]*\&/,'acct=XXXXXX&')
      data3=data2.sub(/SIGNATURE=[^&]*\&/,'SIGNATURE=XXXXXX&')
      data4=data3.sub(/cvv2=[^&]*\&/,'cvv2=XXXXXX&')
    end

  # Method to convert a hash to a string of name and values delimited by '&' as name1=value1&name2=value2...&namen=valuen.
  def hash2cgiString(h)
  #  h.map { |a| a.join('=') }.join('&')
    h.each { |key,value| h[key] = CGI::escape(value.to_s) if (value) }
    h.map { |a| a.join('=') }.join('&')

  end
# Class has a class method which returs the logger to be used for logging.
# All the requests sent and responses received will be logged to a file (filename passed to getLogger method) under logs directroy.
class Logger
    include Singleton
    cattr_accessor :MyLog
    def self.getLogger(filename)

      @@MyLog = Log4r::Logger.new("paypallog")
      # note: The path prepended to filename is based on Rails path structure.
      Log4r::FileOutputter.new('paypal_log',
                       :filename=> "./script/../config/../log/#{filename}",
                       :trunc=>false,
                       :formatter=> MyFormatter)
      @@MyLog.add('paypal_log')
      return @@MyLog
      end
  end
# Class and method to redfine the log4r formatting.
class MyFormatter < Log4r::Formatter
    def format(event)
      # buff = Time.now.strftime("%a %m/%d/%y %H:%M %Z")
      buff = Time.now.strftime("%a %Y-%m-%d %H:%M:%S %Z")
      buff += " - #{Log4r::LNAMES[event.level]}"
      buff += " - #{event.data}\n"
    end
  end
end
