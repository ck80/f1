class CreatePoints < ActiveRecord::Migration[5.1]
  def change
    create_table :points do |t|
      t.string :item
      t.integer :points

      t.timestamps
    end
  end
end
