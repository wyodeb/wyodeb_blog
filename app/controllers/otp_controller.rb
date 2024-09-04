class OtpController < ApplicationController
  def request_otp
    ActiveRecord::Base.transaction do
      user = User.find_or_initialize_by(email: params[:email])

      unless user.valid_email?
        render json: { error: 'Invalid email format' }, status: :unprocessable_entity
        return
      end

      if user.new_record?
        user.username = params[:username] || user.email.split('@').first
        user.skip_password_validation

        unless user.save
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
          return
        end
      end

      user.tokens.delete_all if user.tokens.exists?
      otp = generate_otp
      token = Token.create(user: user, otp: otp, expires_at: 10.minutes.from_now)

      unless token.persisted?
        render json: { errors: token.errors.full_messages }, status: :unprocessable_entity
        return
      end

      UserMailer.otp_email(user, otp).deliver_later

      render json: { message: 'OTP sent successfully' }, status: :ok
    end
  rescue StandardError => e
    Rails.logger.error("Error during OTP request: #{e.message}")
    render json: { error: 'Failed to send OTP' }, status: :internal_server_error
  end

  def verify_otp
    token = Token.joins(:user).find_by(otp: params[:otp], users: { email: params[:email] })

    if token && !token.expired?
      token.destroy

      user = token.user
      user.authentication_token = user.generate_authentication_token
      if user.save
        sign_in(:user, user, store: false)
        render json: { message: 'OTP verified successfully', token: user.authentication_token }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid or expired OTP' }, status: :unauthorized
    end
  end

  private

  def generate_otp
    SecureRandom.random_number(100_000..999_999).to_s
  end
end
