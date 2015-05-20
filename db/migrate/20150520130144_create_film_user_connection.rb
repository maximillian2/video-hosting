class CreateFilmUserConnection < ActiveRecord::Migration
  def change
    create_table :films_users do |t|
      t.belongs_to :film, index: true
      t.belongs_to :user, index: true
    end
  end
end
