class CreateArtists < ActiveRecord::Migration[8.0]
  def change
    create_table :artists do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :first_released_year
      t.integer :number_of_albums_released

      t.timestamps
    end
  end
end
