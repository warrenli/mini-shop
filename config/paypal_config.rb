DEV_CENTRAL_URL="https://developer.paypal.com"
PAYPAL_EC_URL="https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token="


PP_proxy_info = {"USE_PROXY" => false, "ADDRESS" => nil, "PORT" => nil, "USER" => nil, "PASSWORD" => nil }

PP_credentials =  {"USER" => "<API Username>", "PWD" => "<API Password>", "SIGNATURE" => "<API Signature>" }

PP_client_info = { "VERSION" => "56.0", "SOURCE" => "PayPalRubySDKV1.2.0"}

PP_endpoints = {"SERVER" => "api-3t.sandbox.paypal.com", "SERVICE" => "/nvp/"}

PP_pdt_endpoints = {"SERVER" => "www.sandbox.paypal.com", "SERVICE" => "/cgi-bin/webscr"}



PAYPAL_CALL_LOG = "PayPal-call.log"
PAYPAL_IPN_LOG  = "PayPal-ipn.log"
