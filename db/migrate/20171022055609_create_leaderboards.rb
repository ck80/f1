class CreateLeaderboards < ActiveRecord::Migration[5.1]
  def change
    create_table :leaderboards do |t|
      t.integer :year
      t.integer :total_points

      t.timestamps
    end
  end
end
