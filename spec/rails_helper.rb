ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rspec/rails'
require 'devise'
require 'factory_bot_rails'
require 'faker'
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/app/channels/'
  add_filter '/app/models/application_record.rb'
  add_filter 'app/jobs/application_job.rb'
end

abort("The Rails environment is running in production mode!") if Rails.env.production?
# Configure RSpec
RSpec.configure do |config|
  config.before(:each, type: :request) do
    @headers = { 'Content-Type' => 'application/json' }
  end
  config.infer_spec_type_from_file_location!
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.filter_rails_from_backtrace!
  config.use_transactional_fixtures = true
  config.order = :random
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :request
  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end
