raw_config = File.read(RAILS_ROOT + "/config/app_config.yml")
APP_CONFIG = YAML.load(raw_config)[RAILS_ENV].symbolize_keys

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :default => "%Y-%m-%d %H:%M %Z",
  :date_time12  => "%Y-%m-%d %I:%M%p",
  :date_time24  => "%Y-%m-%d %H:%M"
)
