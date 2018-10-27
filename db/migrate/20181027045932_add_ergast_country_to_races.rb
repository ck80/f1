class AddErgastCountryToRaces < ActiveRecord::Migration[5.1]
  def change
    add_column :races, :ergast_country, :string
  end
end
