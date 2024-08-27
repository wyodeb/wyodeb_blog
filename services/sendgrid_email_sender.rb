require 'net/http'
require 'json'
require 'uri'

class SendgridEmailSender
  def initialize(user, otp)
    @user = user
    @otp = otp
    @sendgrid_api_key = Rails.application.credentials.sendgrid[:api_key]
    @template_id = 'd-c1612442f57b41d5aaf182ba47b15d06'
  end

  def send_otp_email
    uri = URI.parse('https://api.sendgrid.com/v3/mail/send')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Authorization'] = "Bearer #{@sendgrid_api_key}"
    request['Content-Type'] = 'application/json'
    payload = {
      personalizations: [
        {
          to: [{ email: @user.email }],
          dynamic_template_data: {
            username: @user.username,
            otp: @otp
          }
        }
      ],
      from: { email: 'hello@wyodeb.io' },
      template_id: @template_id,
      subject: 'Your OTP Code for Wyodeb Blog'
    }.to_json

    request.body = payload

    response = http.request(request)
    log_response(response)
  end

  private

  def log_response(response)
    if response.is_a?(Net::HTTPSuccess)
      Rails.logger.info "Email sent successfully: #{response.body}"
    else
      Rails.logger.error "Failed to send email: #{response.code} #{response.message} #{response.body}"
    end
  end
end
