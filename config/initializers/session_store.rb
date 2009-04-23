# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mini_shop_session',
  :secret      => '12a301ce04f5e7fd86cbf195380d7ea3ec18c85f0333882878c1cf0fbb719e43b076727be4dfe3ffb4c09e674d93f97c84ace9dc1c868ae2a256d2549fef3b5f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
