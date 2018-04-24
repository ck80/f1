class CreateTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :tracks do |t|
      t.string :country
      t.string :circuit
      t.integer :laps
      t.string :svg

      t.timestamps
    end
  end
end
