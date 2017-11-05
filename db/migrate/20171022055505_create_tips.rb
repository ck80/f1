class CreateTips < ActiveRecord::Migration[5.1]
  def change
    create_table :tips do |t|
      t.string :qual_first
      t.string :qual_second
      t.string :qual_third
      t.string :race_first
      t.string :race_second
      t.string :race_third
      t.string :race_tenth
      t.integer :points

      t.timestamps
    end
  end
end
