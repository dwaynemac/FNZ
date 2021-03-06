# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'aasm'
  config.gem 'oauth-plugin'
  config.gem 'oauth'
  config.gem 'authlogic_drc'
  config.gem 'authlogic'
  config.gem 'drc_client'
  config.gem 'acts-as-taggable-on', :source => 'http://gemcutter.org', :version => '2.0.0.rc1'
#  config.gem 'nokogiri'
  config.gem 'searchlogic'
  config.gem 'formtastic'
  config.gem 'will_paginate'
  config.gem 'paperclip'
  config.gem "fastercsv"
  config.gem "http_accept_language"

  config.gem 'money'

#  config.gem 'jnunemaker-validatable', :lib => 'validatable'
  config.gem 'validatable' # gem not mantained since 2008. TODO try in patch jnunemaker-validatable with this fix.

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :en
  config.action_controller.session_store = :active_record_store
end

#Use Nokogiri
#ActiveSupport::XmlMini.backend = 'Nokogiri'
DRCClient.configure(:base_url => DRC_URL, :enable_single_sign_out => true, :require_local_user => true,
                    :user_model => User)

require 'money/bank/google_currency'
# Use Google for currency exchanges
Money.default_bank = Money::Bank::GoogleCurrency.new

