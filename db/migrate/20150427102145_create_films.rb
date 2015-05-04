class CreateFilms < ActiveRecord::Migration
  def change
    create_table :films do |t|
      t.string :name
      t.integer :year
      t.string :genre
      t.integer :rating

      t.timestamps null: false
    end
  end
end
