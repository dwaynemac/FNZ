# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_fnz_session',
  :secret      => 'a235534a78b3c567a1c0da5ef95ab17a13dfd15859fa656ecb469604cce5db650bf1d9a4f26583eab98d7a7b980984047660837bb120645d37ca2a4a8dae2838'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
