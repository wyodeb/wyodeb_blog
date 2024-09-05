class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table "comments", force: :cascade do |t|
      t.text "content"
      t.integer "post_id", null: false
      t.integer "user_id", null: false
      t.integer "parent_id"
      t.timestamps
      t.index ["parent_id"], name: "index_comments_on_parent_id"
      t.index ["post_id"], name: "index_comments_on_post_id"
      t.index ["user_id"], name: "index_comments_on_user_id"
    end

  end
end
