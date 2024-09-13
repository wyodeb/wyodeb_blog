class Category < ApplicationRecord
  has_and_belongs_to_many :posts
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  before_save :prepare_category_name
  after_destroy :remove_unused_categories

  private

  def prepare_category_name
    self.name = name.strip.capitalize
  end

  def remove_unused_categories
    Category.left_joins(:posts).where(posts: { id: nil }).destroy_all
  end
end
