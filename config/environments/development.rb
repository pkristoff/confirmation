Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # config.action_mailer.smtp_settings = {
  #     :address              => "smtp.gmail.com",
  #     :port                 => 587,
  #     :domain               => "gmail.com",
  #     :user_name            => "xyz@gmail.com",
  #     :password             => "yourpassword",
  #     :authentication       => :plain,
  #     :enable_starttls_auto => true
  # }

  config.action_mailer.smtp_settings = {
      address: Rails.application.secrets.email_provider_address,
      port: 587,
      domain: Rails.application.secrets.email_provider_domain,
      authentication: :login,
      enable_starttls_auto: true,
      user_name: Rails.application.secrets.email_provider_username,
      password: Rails.application.secrets.email_provider_password

  }
  # ActionMailer Config
  config.action_mailer.default_url_options = { :host => Rails.application.secrets.domain_name }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  # Send email in development mode?
  config.action_mailer.perform_deliveries = true


  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Rails.application.config.middleware.use ExceptionNotification::Rack,
  #                                         email: {
  #                                             # :deliver_with => :deliver, # Rails >= 4.2.1 do not need this option since it defaults to :deliver_now
  #                                             email_prefix: 'Internal Stmm Confiramtion error: ',
  #                                             sender_address: Rails.application.secrets.admin_email,
  #                                             exception_recipients: Rails.application.secrets.admin_email,
  #                                             email_format: :html
  #
  #                                         }

  Rails.application.routes.default_url_options[:host] = 'domain.com'

end
