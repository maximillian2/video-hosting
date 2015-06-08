class AddDescriptionToFilms < ActiveRecord::Migration
  def change
    add_column :films, :description, :string
  end
end
