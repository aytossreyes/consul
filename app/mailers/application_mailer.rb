class ApplicationMailer < ActionMailer::Base
  helper :settings
  default from: "Consul <#{Rails.application.secrets.default_from_address}>"
  layout 'mailer'
end
