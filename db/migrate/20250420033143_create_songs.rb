class CreateSongs < ActiveRecord::Migration[8.0]
  def change
    create_table :songs do |t|
      t.references :artist, null: false, foreign_key: true
      t.string :title, null:false
      t.string :album_name, null:false
      t.string :genre, null:false

      t.timestamps
    end
  end
end
