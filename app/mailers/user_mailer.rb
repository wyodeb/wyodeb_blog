class UserMailer < ApplicationMailer
  def otp_email(user, otp)
    SendgridEmailSender.new(user, otp).send_otp_email
  end
end
