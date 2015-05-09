class CreateFilms < ActiveRecord::Migration
  def change
    create_table :films do |t|
      t.string :title
      t.string :original_title
      t.string :category
      t.string :link
      t.string :image
      t.string :country

      t.integer :year
      t.string :genres
      t.float :rating

      t.timestamps null: false
    end
  end
end
