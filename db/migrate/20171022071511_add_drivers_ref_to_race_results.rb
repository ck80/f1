class AddDriversRefToRaceResults < ActiveRecord::Migration[5.1]
  def change
    add_reference :race_results, :driver, foreign_key: true
  end
end
