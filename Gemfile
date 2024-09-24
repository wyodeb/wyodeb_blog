source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.0"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 1.4"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
gem 'devise'
gem 'devise-token_authenticatable'
gem 'activerecord-session_store'
gem 'aws-sdk-ssm'




gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem 'rspec-core', '~> 3.13.1'
  gem 'rspec-expectations', '~> 3.13.3'
  gem 'rspec-mocks', '~> 3.13.1'
  gem 'rspec-rails', '~> 7.0.1'

  gem 'factory_bot_rails',  require: false
  gem 'shoulda-matchers', '~> 6.4'
  gem 'faker'
  gem 'dotenv-rails'

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

end

group :test do
  gem 'simplecov', require: false
end


