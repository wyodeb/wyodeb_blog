# app/controllers/concerns/authenticable.rb
module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    if token
      @current_user = User.find_by(authentication_token: token)
      unless @current_user
        Rails.logger.debug "User not found for token: #{token}"
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    else
      Rails.logger.debug "No token provided"
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
