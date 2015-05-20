class Film < ActiveRecord::Base
  has_and_belongs_to_many :users

  validates :title, presence: true
  scope :genres, -> (genre) { where 'genres LIKE ?', "%#{genre}%" }
  scope :category, -> (value) { where category: value }
end
