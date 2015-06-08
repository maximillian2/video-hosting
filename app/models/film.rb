class Film < ActiveRecord::Base
  has_and_belongs_to_many :users

  validates :title, :category, :genres, :country, presence: true
  scope :joined, -> { joins(:users) }
  scope :user_films, -> (current_user_id) { joined.where(users: { id: current_user_id }) }
  scope :genres, -> (current_user_id, genre) { joined.where { (users.id == current_user_id ) & (genres =~ "%#{genre}%") } }
  scope :category, -> (current_user_id, value) { joined.where { (users.id == current_user_id) & (category == "#{value}") } }
  scope :tags, ->(current_user_id, tag) { joined.where { (users.id == current_user_id) & (tags =~ "%#{tag}%") } }
end
