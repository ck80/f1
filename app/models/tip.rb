class Tip < ApplicationRecord
  belongs_to :user
  belongs_to :race
  validates_associated :user
  validates_associated :race
  attr_accessor :modifier_is_admin
  validates :qual_first, :qual_second, :qual_third, :race_first, :race_second, :race_third, :race_tenth, :updated_by, :modifier_is_admin, presence: true
  validates :race_id, uniqueness: { scope: :user_id, message: ": you already have an entry for this race, please edit the existing tip instread of create a new one." }
  validate :unique_entries_on_race_tip_post
  validate :new_tip_cannot_be_past_quali_start, unless: -> { modifier_is_admin == "true" }
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

def new_tip_cannot_be_past_quali_start
  errors.add(:race_id, "- can't submit new tip after qualification session start time") if
    Time.current > race.ical_dtstart
end

def update_race_tip_points
  # set @year as for some reason it does not carry accross from tips_controller... this is a temporary bandaid as it only works for current year.
  @year = Time.current.year.to_s
  @tips = Tip.joins(:race).where('races.year': @year)
    
  #calculate quali points

  @nestedpointsArray = []
  $i = 0
  @tips.each do |tip|
    @pointsArray = []

    # calculate quali first place selection
    @pointsArray << \
    if QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_first), year: @year).id)).nil? then 0
    elsif QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_first), year: @year).id)).position == 0 then 0
    elsif Point.find_by(item: "q1st").points - (1 - QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_first), year: @year).id)).position).abs < 0 then 0
    else Point.find_by(item: "q1st").points - (1 - QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_first), year: @year).id)).position).abs
    end
    
    # calculate quali second place selection
    @pointsArray << \
    if QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_second), year: @year).id)).nil? then 0
    elsif QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_second), year: @year).id)).position == 0 then 0
    elsif Point.find_by(item: "q2nd").points - (2 - QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_second), year: @year).id)).position).abs < 0 then 0
    else Point.find_by(item: "q2nd").points - (2 - QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_second), year: @year).id)).position).abs
    end
    
    # calculate quali third place selection
    @pointsArray << \
    if QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_third), year: @year).id)).nil? then 0
    elsif QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_third), year: @year).id)).position == 0 then 0
    elsif Point.find_by(item: "q3rd").points - (3 - QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_third), year: @year).id)).position).abs < 0 then 0
    else Point.find_by(item: "q3rd").points - (3 - QualiResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.qual_third), year: @year).id)).position).abs
    end

    # calculate race first place selection
    race_first_points = Point.find_by(race_position: 1).points
    race_first_driver = RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: tip.race_first, year: @year).id))
    if RaceResult.find_by(race_id: tip.race_id, driver_id: (Driver.find_by(abbr_name: tip.race_first, year: @year).id)).nil? then selection_race_position = 0 else selection_race_position = RaceResult.find_by(race_id: tip.race_id, driver_id: (Driver.find_by(abbr_name: tip.race_first, year: @year).id)).position end
    if Point.find_by(race_position: selection_race_position).nil? then selection_race_points = 0 else selection_race_points = Point.find_by(race_position: selection_race_position).points end
    @pointsArray << \
    if race_first_driver.nil? then 0
    elsif race_first_driver.position == 0 then 0
    elsif [selection_race_points, race_first_points].min - (1 - selection_race_position).abs < 0 then 0
    else [selection_race_points, race_first_points].min - (1 - selection_race_position).abs
    end
    
    # calculate race second place selection
    race_second_points = Point.find_by(race_position: 2).points
    race_second_driver = RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: tip.race_second, year: @year).id))
    if RaceResult.find_by(race_id: tip.race_id, driver_id: (Driver.find_by(abbr_name: tip.race_second, year: @year).id)).nil? then selection_race_position = 0 else selection_race_position = RaceResult.find_by(race_id: tip.race_id, driver_id: (Driver.find_by(abbr_name: tip.race_second, year: @year).id)).position end
    if Point.find_by(race_position: selection_race_position).nil? then selection_race_points = 0 else selection_race_points = Point.find_by(race_position: selection_race_position).points end
    @pointsArray << \
    if race_second_driver.nil? then 0
    elsif race_second_driver.position == 0 then 0
    elsif [selection_race_points, race_second_points].min - (2 - selection_race_position).abs < 0 then 0
    else [selection_race_points, race_second_points].min - (2 - selection_race_position).abs
    end

    # calculate race third place selection
    race_third_points = Point.find_by(race_position: 3).points
    race_third_driver = RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: tip.race_third, year: @year).id))
    if RaceResult.find_by(race_id: tip.race_id, driver_id: (Driver.find_by(abbr_name: tip.race_third, year: @year).id)).nil? then selection_race_position = 0 else selection_race_position = RaceResult.find_by(race_id: tip.race_id, driver_id: (Driver.find_by(abbr_name: tip.race_third, year: @year).id)).position end
    if Point.find_by(race_position: selection_race_position).nil? then selection_race_points = 0 else selection_race_points = Point.find_by(race_position: selection_race_position).points end
    @pointsArray << \
    if race_third_driver.nil? then 0
    elsif race_third_driver.position == 0 then 0
    elsif [selection_race_points, race_third_points].min - (3 - selection_race_position).abs < 0 then 0
    else [selection_race_points, race_third_points].min - (3 - selection_race_position).abs
    end

    # calculate race tenth bonus selection
    race_tenth_bonus_points = Point.find_by(race_position: 99).points
    race_tenth_driver = RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: tip.race_tenth, year: @year).id))
    if RaceResult.find_by(race_id: tip.race_id, driver_id: (Driver.find_by(abbr_name: tip.race_tenth, year: @year).id)).nil? then selection_race_position = 0 else selection_race_position = RaceResult.find_by(race_id: tip.race_id, driver_id: (Driver.find_by(abbr_name: tip.race_tenth, year: @year).id)).position end
    if Point.find_by(race_position: selection_race_position).nil? then selection_race_points = 0 else selection_race_points = Point.find_by(race_position: selection_race_position).points end
    @pointsArray << \
    if RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_tenth), year: @year).id)).nil? then 0
    elsif RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_tenth), year: @year).id)).position != 10 then 0
    elsif RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by(abbr_name: (tip.race_tenth), year: @year).id)).position == 10 then 15
    end

    @pointsHash = {user: tip.user.email, race: tip.race.country, points: @pointsArray, race_points: @pointsArray.sum }
    @nestedpointsArray << @pointsHash
    tip.update_columns(qual_first_points: (@pointsHash[:points][0]), qual_second_points: (@pointsHash[:points][1]), qual_third_points: (@pointsHash[:points][2]), \
    race_first_points: (@pointsHash[:points][3]), race_second_points: (@pointsHash[:points][4]), race_third_points: (@pointsHash[:points][5]), \
    race_tenth_points: (@pointsHash[:points][6]), race_total_points: (@pointsHash[:points].sum))
    $i +=1  
  end

end