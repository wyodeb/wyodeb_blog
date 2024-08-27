# app/controllers/sessions_controller.rb
class SessionsController < Devise::SessionsController
  skip_before_action :verify_signed_out_user

  def create
    resource = User.find_for_database_authentication(email: params[:email])
    if resource && resource.valid_password?(params[:password])
      sign_in(resource_name, resource)
      resource.authentication_token = resource.generate_authentication_token
      resource.save # Ensure the token is persisted

      render json: { token: resource.authentication_token }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def destroy
    token = params[:token]
    resource = User.find_by(authentication_token: token)

    if resource && resource.valid_token?(token)
      resource.update(authentication_token: nil)
      render json: { message: 'Signed out successfully' }, status: :ok
    else
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    end
  end

end
