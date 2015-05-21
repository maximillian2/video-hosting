class Film < ActiveRecord::Base
  has_and_belongs_to_many :users

  validates :title, presence: true
  scope :joined, -> { joins(:users) }
  scope :user_films, -> (current_user_id) { joined.where(users: { id: current_user_id }) }
  scope :genres, -> (current_user_id, genre) { joined.where { (users.id == current_user_id ) & (genres =~ "%#{genre}%") } }
  scope :category, -> (current_user_id, value) { joined.where { (users.id == current_user_id) & (category == "#{value}") } }
end
