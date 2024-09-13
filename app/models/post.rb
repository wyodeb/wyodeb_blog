class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :categories
  enum :status, { draft: 0, published: 1 }
  before_validation :generate_slug, on: :create
  validates :slug, presence: true, uniqueness: true
  before_save :calculate_reading_stats, if: :will_save_change_to_content?

  private

  def generate_slug
    self.slug = title.parameterize if title.present?
  end

  def calculate_reading_stats
    self.word_count = count_words(content)
    self.reading_time = calculate_reading_time(word_count)
  end

  def count_words(text)
    count = 0
    in_word = false
    text.each_char do |char|
      if char.match?(/[\w-]/)
        if in_word
          in_word = false
        else
          count += 1
          in_word = true
        end
      else
        in_word = false
      end
    end
    count
  end

  def calculate_reading_time(word_count)
    words_per_minute = 200
    (word_count.to_f / words_per_minute).ceil
  end
end
