class Film < ActiveRecord::Base
  validates :title, presence: true
  # validates :rating, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 11 }
  # validates :year, numericality: { only_integer: true, greater_than: 1940, less_than: Time.new.year+1 }

  scope :genres, -> (category) { where genres: category}
end
