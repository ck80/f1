class Tip < ApplicationRecord
  belongs_to :user
  belongs_to :race
  validates_associated :user
  validates_associated :race
  validates :qual_first, :qual_second, :qual_third, :race_first, :race_second, :race_third, :race_tenth, :updated_by, presence: true
  validates :race_id, uniqueness: { scope: :user_id, message: ": you already have an entry for this race, please edit the existing tip instread of create a new one." }
  validate :unique_entries_on_race_tip_post
##  validates :race_id, uniqueness: { scope: :year, message: "should have once per year" }  
end

def unique_entries_on_race_tip_post
  #avoid duplicate entried for qualies and race tips
  my_race_array = []
  [race_first, race_second, race_third, race_tenth].each do |i| 
    my_race_array << i unless i.length < 1 #empty string don't go in the array
  end
  unless my_race_array.uniq.length == my_race_array.count
    errors.add(:race_first, "- has to be unique")
    errors.add(:race_second, "- has to be unique")
    errors.add(:race_third, "- has to be unique")
    errors.add(:race_tenth, "- has to be unique")
    false
  end 
  my_qual_array = []
  [qual_first, qual_second, qual_third].each do |i| 
    my_qual_array << i unless i.length < 1 #empty string don't go in the array
  end
  unless my_qual_array.uniq.length == my_qual_array.count
    errors.add(:qual_first, "- has to be unique")
    errors.add(:qual_second, "- has to be unique")
    errors.add(:qual_third, "- has to be unique")
    false
  end 
end