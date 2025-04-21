class Song < ApplicationRecord
  belongs_to :artist

  GENRES = %w[rnb country classic rock jazz]

  validates :title, presence: true
  validates :album_name, presence:true
  validates :genre, presence:true, inclusion: {in: GENRES, message: "must be one of: #{GENRES.join(', ')}"}
end
