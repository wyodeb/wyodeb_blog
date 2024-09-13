def fetch_secret(name)
  return ENV[name] if Rails.env.development?
  ssm_client = Aws::SSM::Client.new(region: ENV['AWS_REGION'])
  ssm_client.get_parameter(name: name, with_decryption: true).parameter.value
end

poster_email = Rails.env.development? ? 'poster@example.com' : fetch_secret('POSTER_EMAIL')
poster_password = Rails.env.development? ? 'password123' : fetch_secret('POSTER_PASSWORD')

User.find_or_create_by!(email: poster_email) do |user|
  user.password = poster_password
  user.password_confirmation = poster_password
  user.role = :poster
end
puts "User created with email: #{poster_email}"
