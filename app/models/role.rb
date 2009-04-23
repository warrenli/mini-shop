# Defines named roles for users that may be applied to
# objects in a polymorphic fashion. For example, you could create a role
# "moderator" for an instance of a model (i.e., an object), a model class,
# or without any specification at all.
class Role < ActiveRecord::Base
  has_many :roles_users, :dependent => :delete_all
  has_many :users, :through => :roles_users
  belongs_to :authorizable, :polymorphic => true
  def to_s
     description = "Is_"
     description << self.name.capitalize
     if self.authorizable_type
       if self.authorizable_id
         description << "_of_some_"
         description << self.authorizable_type.capitalize
       else
         description << "_of_"
         description << self.authorizable_type.capitalize
       end
     end
     description
  end
end
