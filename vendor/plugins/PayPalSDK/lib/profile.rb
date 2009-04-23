# The module has a class which holds merchant's API credentials and PayPal endpoint information.

module PayPalSDKProfiles
  class Profile
    cattr_accessor :credentials
    cattr_accessor :endpoints
    cattr_accessor :client_info
    cattr_accessor :proxy_info
    cattr_accessor :PAYPAL_EC_URL
    cattr_accessor :DEV_CENTRAL_URL


    # Redirect URL for Express Checkout
    @@PAYPAL_EC_URL="https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token="

    @@DEV_CENTRAL_URL="https://developer.paypal.com"
    ###################################################################################################
    #  NOTE: Production code should NEVER expose API credentials in any way! 
    #        They must be managed securely in your application.
    #        To generate a Sandbox API Certificate, follow these steps: 
    #           https://www.paypal.com/IntegrationCenter/ic_certificate.html
  #####################################################################################################
    # specify the 3-token values.
    @@credentials =  {"USER" => "sdk-three_api1.sdk.com", 
                      "PWD" => "QFZCWN5HZM8VBG7Q", 
                      "SIGNATURE" => "A.d9eRKfd1yVkRrtmMfCFLTqa6M9AyodL0SJkhYztxUi8W9pCXF6.4NI" }

    # endpoint of PayPal server against which call will be made.
    @@endpoints = {"SERVER" => "api-3t.sandbox.paypal.com", "SERVICE" => "/nvp/"}

    # Proxy information of the client environment.
    @@proxy_info = {"USE_PROXY" => false, "ADDRESS" => nil, "PORT" => nil, "USER" => nil, "PASSWORD" => nil }

    # Information needed for tracking purposes.
    @@client_info = { "VERSION" => "56.0", "SOURCE" => "PayPalRubySDKV1.2.0"}

    def initialize
      config
    end

    def config
      @config ||= YAML.load_file("./script/../config/paypal.yml")
    end

    def m_use_proxy
      @config[:USE_PROXY]
    end
  end

end



