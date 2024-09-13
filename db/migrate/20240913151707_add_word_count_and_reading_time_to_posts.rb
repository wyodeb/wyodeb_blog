class AddWordCountAndReadingTimeToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :word_count, :integer
    add_column :posts, :reading_time, :integer
  end
end
