require_relative "boot"

# We cherry pick dependencies defined in
# https://github.com/rails/rails/blob/v7.0.7/railties/lib/rails/all.rb
# require "rails/all"
require "rails"

[
  'active_record/railtie',
#  'active_storage/engine',
  'action_controller/railtie',
  'action_view/railtie',
  'action_mailer/railtie',
  'active_job/railtie',
  'action_cable/engine',
#  'action_mailbox/engine',
#  'action_text/engine',
  'rails/test_unit/railtie'
].each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SpokerMaster
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
