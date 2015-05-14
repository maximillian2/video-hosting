class Film < ActiveRecord::Base
  validates :title, presence: true
  scope :genres, -> (genre) { where 'genres LIKE ?', "%#{genre}%" }
  scope :category, -> (value) { where category: value }
end
