class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :key
      t.string :one
      t.string :two
      t.string :three
      t.string :four
      t.string :five

      t.timestamps null: false
    end
  end
end
