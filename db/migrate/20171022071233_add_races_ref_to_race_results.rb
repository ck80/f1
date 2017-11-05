class AddRacesRefToRaceResults < ActiveRecord::Migration[5.1]
  def change
    add_reference :race_results, :race, foreign_key: true
  end
end
