class AddRacesRefToTips < ActiveRecord::Migration[5.1]
  def change
    add_reference :tips, :race, foreign_key: true
  end
end
