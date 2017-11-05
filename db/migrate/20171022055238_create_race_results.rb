class CreateRaceResults < ActiveRecord::Migration[5.1]
  def change
    create_table :race_results do |t|
      t.integer :position

      t.timestamps
    end
  end
end
