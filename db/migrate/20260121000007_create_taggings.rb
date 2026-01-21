class CreateTaggings < ActiveRecord::Migration[8.1]
  def change
    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: true
      t.string :taggable_type, null: false
      t.bigint :taggable_id, null: false

      t.timestamps
    end

    add_index :taggings, %i[taggable_type taggable_id]
    add_index :taggings, %i[tag_id taggable_type taggable_id], unique: true, name: "index_taggings_uniqueness"
  end
end
