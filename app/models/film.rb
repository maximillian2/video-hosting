class Film < ActiveRecord::Base
  validates :title, presence: true
  # validates :rating, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 11 }
  # validates :year, numericality: { only_integer: true, greater_than: 1940, less_than: Time.new.year+1 }

  # FIXME move @films.where('genres LIKE ?', "%#{params[:category]}%") logic here
  scope :genres, -> (genre) { where genres: genre }
  # TODO add category scope here
  scope :category, -> (value) { where category: value }
end
