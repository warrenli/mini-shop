class InitialSetup < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.string      :session_id, :null => false
      t.text        :data
      t.timestamps
    end

    add_index :sessions, :session_id

    create_table :users do |t|
      t.string      :login,                 :null => false
      t.string      :email,                 :null => false
      t.string      :fullname,              :null => false, :limit => 100
      t.boolean     :active,                :null => false, :default => false
      t.integer     :login_count,           :null => false, :default => 0
      t.string      :perishable_token,      :null => false
      t.string      :persistence_token,     :null => false
      t.string      :time_zone,             :null => false, :default => 'Hong Kong'
      t.string      :crypted_password
      t.string      :password_salt
      t.datetime    :last_request_at
      t.datetime    :last_login_at
      t.datetime    :current_login_at
      t.string      :last_login_ip
      t.string      :current_login_ip
      # t.string    :single_access_token,   :null => false # optional

      t.timestamps
    end

    add_index(:users, :login, :unique => true)
    add_index(:users, :email, :unique => true)

    create_table :roles_users, :id => false, :force => true  do |t|
      t.integer :user_id, :role_id
      t.timestamps
    end

    add_index(:roles_users, [:user_id, :role_id])
    add_index(:roles_users, :role_id)

    create_table :roles, :force => true do |t|
      t.string  :name, :authorizable_type, :limit => 40
      t.integer :authorizable_id
      t.timestamps
    end

    add_index(:roles, [:authorizable_type, :authorizable_id])
    add_index(:roles, :name)

    user = User.create do |u|
      u.login = 'minishopadmin'
      u.fullname = "Web Master"
      u.email = 'admin@example.com'
      u.password = u.password_confirmation = 'secretpassword'
      u.active = true
      u.has_role 'site_admin'
    end

    create_table :user_emails do |t|
      t.integer     :user_id,                       :null => false
      t.string      :new_email,     :limit => 100,  :null => false
      t.string      :old_email,     :limit => 100,  :null => false
      t.string      :request_code,                  :null => false
      t.datetime    :request_expiration_date,       :null => false
      t.datetime    :confirmed_at,                  :null => true
      t.string      :status,                        :null => false

      t.timestamps
    end

    add_index(:user_emails, :user_id)
    add_index(:user_emails, :request_code)
    add_index(:user_emails, :request_expiration_date)
  end

  def self.down
    # Drop all tables
    drop_table :sessions
    drop_table :users
    drop_table :user_emails
  end
end

