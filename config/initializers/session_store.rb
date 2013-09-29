# Be sure to restart your server when you modify this file.

config = YAML.load(File.open('config/gct.yml'))

GCT::Application.config.session_store :cookie_store, key: '_gct_session', :domain => ".#{config['site']['host']}" 