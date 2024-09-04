require 'net/http'
require 'json'
require 'uri'

class SendgridEmailSender
  def initialize(user, otp)
    @user = user
    @otp = otp
    @sendgrid_api_key = ENV["SENDGRID_API_KEY"]
    @template_id = ENV["SENDGRID_OTP_TEMPLATE_ID"]
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
            subject: 'Your OTP Code for Wyodeb Blog',
            username: @user.username,
            otp: @otp
          }
        }
      ],
      from: { email: 'wyodeb@wyodeb.io' },
      template_id: @template_id,
      reply_to: { email: 'wyodeb@wyodeb.io' }
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
