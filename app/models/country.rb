class Country < ActiveRecord::Base
  validates_presence_of   :name,         :alpha_3_code, :alpha_2_code
  validates_length_of     :alpha_2_code, :is => 2
  validates_length_of     :alpha_3_code, :is => 3

  def initialize(attributes = nil)
    super
    self.official_name ||= name unless attributes && attributes.include?(:official_name)
  end
end
