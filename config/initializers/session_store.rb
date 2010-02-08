# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_alaCarte_session',
  :secret      => 'f8dc8bc04420a4b081aa4ce01c29ef4d36f2d534d912fc352d20a10ecb000ce71dc67ccbf631bfb1417de8af2f5297d3d28ed1cb41ca049ef002d77a7d026dc9'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
