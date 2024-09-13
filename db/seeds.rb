# db/seeds.rb


def fetch_secret(name)
  return ENV[name] if Rails.env.development?


  ssm_client = Aws::SSM::Client.new(region: ENV['AWS_REGION'])
  ssm_client.get_parameter(name: name, with_decryption: true).parameter.value
end

# Define secrets
admin_email = Rails.env.development? ? 'poster@example.com' : fetch_secret('ADMIN_EMAIL')
admin_password = Rails.env.development? ? 'password123' : fetch_secret('ADMIN_PASSWORD')

# Create or update the admin user
User.find_or_create_by!(email: admin_email) do |user|
  user.password = admin_password
  user.password_confirmation = admin_password
  user.role = :admin  # Adjust role as needed
end

puts "Admin user created with email: #{admin_email}"
