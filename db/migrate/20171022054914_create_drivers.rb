class CreateDrivers < ActiveRecord::Migration[5.1]
  def change
    create_table :drivers do |t|
      t.integer :year
      t.string :name
      t.string :abbr_name
      t.integer :car_number
      t.string :team

      t.timestamps
    end
  end
end
