# Configuration
Searchlogic::Config.configure do |config|
  # config.search.per_page = config.helpers.per_page_select_choices.first.last
  config.search.per_page = 10
  config.helpers.per_page_select_choices = [["10", 10], ["25", 25], ["50", 50], ["100", 100], ["All", nil]]
end
