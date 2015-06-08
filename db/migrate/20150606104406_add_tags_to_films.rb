class AddTagsToFilms < ActiveRecord::Migration
  def change
    add_column :films, :tags, :string
  end
end
