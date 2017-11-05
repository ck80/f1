class CreateRaces < ActiveRecord::Migration[5.1]
  def change
    create_table :races do |t|
      t.integer :year
      t.integer :race_number
      t.string :country

      t.timestamps
    end
  end
end
