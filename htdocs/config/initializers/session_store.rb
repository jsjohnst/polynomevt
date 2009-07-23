# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_htdocs_session',
  :secret      => 'f6c3969d30c2981e8715a571b1086453dca3983a0898cf7abeb118b9e2ea7f4edfd164cf75cfcca7a7fb605bf1194f992e0257019d982e27ccd14870b4621cb2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
