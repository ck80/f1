class AddColumnsToRace < ActiveRecord::Migration[5.1]
  def change
    add_column :races, :ical_uid, :string
    add_column :races, :ical_dtstart, :datetime
    add_column :races, :ical_summary, :string
  end
end
