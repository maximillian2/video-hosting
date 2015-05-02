class Film < ActiveRecord::Base
  validates :name, presence: true
  validates :rating, presence: true
end
