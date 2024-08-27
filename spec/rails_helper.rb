require_relative '../config/environment'
require 'factory_bot_rails'
require 'rspec/rails'

abort("The Rails environment is running in production mode!") if Rails.env.production?
# Configure RSpec
RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.filter_rails_from_backtrace!
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end
