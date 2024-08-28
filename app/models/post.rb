class Post < ApplicationRecord
  belongs_to :user
  enum status: {draft: 0, published: 1}
  before_validation :generate_slug, on: :create
  validates :slug, presence: true, uniqueness: true

  private
  def generate_slug
    self.slug = title.parameterize if title.present?
  end
end
