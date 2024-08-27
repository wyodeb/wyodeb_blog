# app/controllers/otp_controller.rb
class OtpController < ApplicationController
  def request_otp
    ActiveRecord::Base.transaction do
      user = User.find_or_initialize_by(email: params[:email])
      if user.new_record?
        user.username = params[:username] || user.email.split('@').first
        user.skip_password_validation
        unless user.save
          render json: {errors: user.errors.full_messages}, status: 401
          return

        end
      end
      user.tokens.delete_all
      otp = generate_otp
      token = Token.create(user: user, otp: otp, expires_at: 10.minutes.from_now)

      unless token.persisted?
        render json: { errors: token.errors.full_messages }, status: 401
        return

      end

      UserMailer.otp_email(user, otp).deliver_now
    end

    head :ok
  rescue => e
    Rails.logger.error("Error during OTP request: #{e.message}")
    head :internal_server_error
  end

  def verify_otp
    token = Token.joins(:user).find_by(otp: params[:otp], users: {email: params[:email]})
    logger.debug "Token found: #{token.inspect}"
    logger.debug "Token expired: #{token&.expires_at?}"
    if token && !token.expired?
      # You can manually set the current_user or handle authentication as needed
      token.destroy
      render json: { message: 'OTP verified successfully' }
    else
      head :unauthorized
    end
  end

  private

  def generate_otp
    rand(100000..999999).to_s
  end
end
