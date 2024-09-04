module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
  end

  private

  def set_current_user
    token = request.headers['Authorization']&.split(' ')&.last
    if token
      @current_user = User.find_by(authentication_token: token)
      unless @current_user
        Rails.logger.debug "User not found for token: #{token}"
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  end

  def current_user
    @current_user
  end

end
