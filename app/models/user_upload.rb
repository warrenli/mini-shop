class UserUpload < ActiveRecord::Base
  validates_numericality_of :position, :integer_only => true, :gt => 0

=begin
#  attr_accessor delete_data
  def delete_data=(value)
        puts "***********************"
        puts "*  value = " + value
        puts "*  assign delete_data = " + (!value.to_i.zero?).inspect
        puts "***********************"
    @delete_data = !value.to_i.zero?
  end

  def delete_data
        puts "***********************"
        puts "*  delete_data = " + (!!@delete_data).inspect
        puts "***********************"
    !!@delete_data
  end

  alias_method :delete_data?, :delete_data

  before_validation :clear_data

  def clear_data
        puts "***********************"
        puts "*  clear_data start ..." + (self.data_file_name.nil? ? "" : self.data_file_name)
        puts "***********************"
    if delete_data? && !data.dirty?
        self.data = nil 
        puts "***********************"
        puts "*  clear_data: data DELETED"
        puts "***********************"
    else
        puts "***********************"
        puts "*  clear_data: data UNCHANGED"
        puts "***********************"
    end
  end
=end
  def after_save
    if self.data_file_name.nil?
       self.destroy
    else

    end
  end

end
