# Be sure to restart your server when you modify this file.

config = YAML.load(File.open('config/gct.yml'))

Gct::Application.config.session_store :cookie_store, key: '_gct_session', :domain => ".#{config['site']['host']}" 

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Gct::Application.config.session_store :active_record_store
