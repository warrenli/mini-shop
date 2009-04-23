LOCALES_DIRECTORY = "#{RAILS_ROOT}/config/locales"

%w{yml rb}.each do |type|
  I18n.load_path += Dir.glob("#{LOCALES_DIRECTORY}/**/*.#{type}")
end


I18n.backend.send(:init_translations) 
AVAILABLE_LOCALES = I18n.backend.send(:instance_variable_get, :@translations).keys.collect { |l| l.to_s }


# I18n.default_locale = 'en-US'
# I18n.locale         = 'en-US'

I18n.default_locale = 'zh-HK'
I18n.locale         = 'zh-HK'
