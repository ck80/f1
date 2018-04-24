class AddRacePositionsToPoints < ActiveRecord::Migration[5.1]
  def change
    add_column :points, :quali_position, :integer
    add_column :points, :race_position, :integer
  end
end
