class Tip < ApplicationRecord
  belongs_to :user
  belongs_to :race
  validates_associated :user
  validates_associated :race
  validates :qual_first, :qual_second, :qual_third, :race_first, :race_second, :race_third, :race_tenth, :updated_by, presence: true
  validates :race_id, uniqueness: { scope: :user_id, message: ": you already have an entry for this race, please edit the existing tip instread of create a new one." }
  validate :unique_entries_on_race_tip_post
  after_save :update_race_tip_points
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

def update_race_tip_points
  @tips = Tip.all
  
  #calculate quali points

  
  @nestedpointsArray = []
  $i = 0
  @tips.each do |tip|
    @pointsArray = []
    @pointsArray << \
    if QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_first)).id)).nil?
      then 0
    elsif QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_first)).id)).position == 0
      then 0
    elsif Point.find_by(item: "q1st").points - (1 - QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_first)).id)).position).abs < 0
      then 0
    else Point.find_by(item: "q1st").points - (1 - QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_first)).id)).position).abs
    end
    @pointsArray << \
    if QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_second)).id)).nil?
      then 0
    elsif QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_second)).id)).position == 0
      then 0
    elsif Point.find_by(item: "q2nd").points - (2 - QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_second)).id)).position).abs < 0
      then 0
    else Point.find_by(item: "q2nd").points - (2 - QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_second)).id)).position).abs
    end
    @pointsArray << \
    if QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_third)).id)).nil?
      then 0
    elsif QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_third)).id)).position == 0
      then 0
    elsif Point.find_by(item: "q3rd").points - (3 - QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_third)).id)).position).abs < 0
      then 0
    else Point.find_by(item: "q3rd").points - (3 - QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_third)).id)).position).abs
    end
    @pointsArray << \
    if RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_first)).id)).nil?
      then 0
    elsif RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_first)).id)).position == 0
      then 0
    elsif Point.find_by(item: "r1st").points - (1 - RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_first)).id)).position).abs < 0
      then 0
    else Point.find_by(item: "r1st").points - (1 - RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_first)).id)).position).abs
    end
    @pointsArray << \
    if RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_second)).id)).nil?
      then 0
    elsif RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_second)).id)).position == 0
      then 0
    elsif Point.find_by(item: "r2nd").points - (2 - RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_second)).id)).position).abs < 0
      then 0
    else Point.find_by(item: "r2nd").points - (2 - RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_second)).id)).position).abs
    end
    @pointsArray << \
    if RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_third)).id)).nil?
      then 0
    elsif RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_third)).id)).position == 0
      then 0
    elsif Point.find_by(item: "r3rd").points - (3 - RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_third)).id)).position).abs < 0
      then 0
    else Point.find_by(item: "r3rd").points - (3 - RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_third)).id)).position).abs
    end
    @pointsArray << \
    if RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_tenth)).id)).nil?
      then 0
    elsif RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_tenth)).id)).position != 10
      then 0
    elsif RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_tenth)).id)).position == 10
      then 15
    end
    @pointsHash = {user: tip.user.email, race: tip.race.country, points: @pointsArray, race_points: @pointsArray.sum }
    @nestedpointsArray << @pointsHash
    # note: using update_columns below instread of regular update to skip callback which results in an infinit loop due to this fucntion updating the same record.
    tip.update_columns(qual_first_points: (@pointsHash[:points][0]), qual_second_points: (@pointsHash[:points][1]), qual_third_points: (@pointsHash[:points][2]), \
    race_first_points: (@pointsHash[:points][3]), race_second_points: (@pointsHash[:points][4]), race_third_points: (@pointsHash[:points][5]), \
    race_tenth_points: (@pointsHash[:points][6]), race_total_points: (@pointsHash[:points].sum))
    $i +=1  
  end
  
  #render plain: @nestedpointsArray.join("\n")
  
end