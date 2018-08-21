class CreateBusnums < ActiveRecord::Migration
  def change
    create_table :busnums do |t|
      t.string :number

      t.timestamps null: false
    end
  end
end
