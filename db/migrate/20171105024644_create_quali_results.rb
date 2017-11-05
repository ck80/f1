class CreateQualiResults < ActiveRecord::Migration[5.1]
  def change
    create_table :quali_results do |t|
      t.integer :position
      t.integer :driver_id
      t.integer :race_id

      t.timestamps
    end
  end
end
