class Artist < ApplicationRecord
  belongs_to :user
  has_many :songs, dependent: :destroy
  validates :first_released_year, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1800 }
  validates :number_of_albums_released, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
