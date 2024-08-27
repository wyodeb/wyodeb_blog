class User < ApplicationRecord
  enum :role, {:poster=>1, :commenter=>2}

  has_many :tokens, dependent: :destroy
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  # Enable token authentication only if `authentication_token` is present
  devise :token_authenticatable if attribute_names.include?('authentication_token')

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Token generation logic
  def generate_authentication_token
    loop do
      token = Devise.friendly_token(128)
      break token unless self.class.exists?(authentication_token: token)
    end
  end

  def skip_password_validation
    @skip_password_validation = true
  end

  def password_required?
    return false if @skip_password_validation
    super
  end

  def valid_token?(token)
    authentication_token == token
  end
end
