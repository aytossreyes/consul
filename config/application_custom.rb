module Consul
  class Application < Rails::Application
    require Rails.root.join('lib/custom/census_api') unless Rails.env.test?
    require Rails.root.join('lib/custom/sms_api') unless Rails.env.test?
  end
end
