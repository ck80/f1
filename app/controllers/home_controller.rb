class HomeController < ApplicationController

  def index
    @users = User.all
  end
  
  def show
    @users = User.all
  end
  
  class Entry
  	def initialize(race_country, place, car, driver, team)
  		@race_country = race_country
      @place = place
  		@car = car
      @driver = driver
      @team = team
  	end
    attr_reader :race_country
  	attr_reader :place
  	attr_reader :car
    attr_reader :driver
    attr_reader :team
  end
  
  def fetch_result_action
    # load HTML parser
    require 'rubygems'
    require 'nokogiri'
    require 'open-uri'
    
    # fetch F1 HTML page including list of races
    page = "https://www.formula1.com/en/championship/races/2017.html"
    doc = Nokogiri::HTML(open(page))
    section=doc.css('.inner-wrap')
    element=section.css('a')
    
    # put element into an array @resultsArray
    @resultsArray = []
    $i = 0
    while $i < element.length
      item = element[$i]["href"]
      @resultsArray << item
      $i +=1
    end

    # pull out countries for each race and drop any non-race items from the array.  We are left with a clean list of countries in @raceArray
    @raceArray = []
    $i = 0
    while $i < @resultsArray.length-2 # minus 2 to drop non-race elements
      race = @resultsArray[$i].split("/").last.split(".").first.gsub("_", " ") # gsub replaces underscores with spaces to tidy up
      @raceArray << race
      $i +=1
    end
    
    # now fetch qualification and race results for each race and store in @allqualiresultsArray and @allraceresultsArray
    @allqualiresultsArray = []
    @allraceresultsArray = []
    $i = 0
    while $i < @raceArray.length
      
      @quali_results = QualiResult.joins(:race, :driver)
      @country = @raceArray[$i]
      @year = 2017
      seasonstartid = 959 # first race id
      raceid = seasonstartid + $i
      page = "https://www.formula1.com/en/results.html/#{@year}/races/#{raceid}/#{@country.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}/qualifying.html"
      doc = Nokogiri::HTML(open(page))   
      
      table=doc.css('table.resultsarchive-table')
      rows=table.css('tr')
      
      @qualiresultsArray = []
      $j = 1
      while $j < rows.length
        race_country = @country
        place = rows[$j].css('td')[1].text
        car = rows[$j].css('td')[2].text
        driver = rows[$j].css('td')[3].text.split.last
        team = rows[$j].css('td')[4].text
        @qualiresultsArray << Entry.new(race_country, place, car, driver, team)
        $j +=1
      end
      @allqualiresultsArray << @qualiresultsArray
      
      page = "https://www.formula1.com/en/results.html/#{@year}/races/#{raceid}/#{@country.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}/race-result.html"
      doc = Nokogiri::HTML(open(page))   
    
      table=doc.css('table.resultsarchive-table')
      rows=table.css('tr')
    
      @raceresultsArray = []  
      $j = 1
      while $j < rows.length
        race_country = @country
        place = rows[$j].css('td')[1].text
        car = rows[$j].css('td')[2].text
        driver = rows[$j].css('td')[3].text.split.last
        team = rows[$j].css('td')[4].text
        @raceresultsArray << Entry.new(race_country, place, car, driver, team)
        $j +=1
      end
      @allraceresultsArray << @raceresultsArray  
      $i +=1
    end
    
#    render plain: @allqualiresultsArray 
    
    # commit results to DB
    @allqualiresultsArray.each do |race|
      race.each do |result|
        result.race_country
        result.place
        result.car
        result.driver
        result.team
        x = Driver.find_by(abbr_name: result.driver).id
        y = Race.find_by(country: result.race_country).id
        r = QualiResult.new
        r.position = result.place
        r.race_id = y
        r.driver_id = x
        r.save
      end
    end
    
    @allraceresultsArray.each do |race|
      race.each do |result|
        result.race_country
        result.place
        result.car
        result.driver
        result.team
        x = Driver.find_by(abbr_name: result.driver).id
        y = Race.find_by(country: result.race_country).id
        r = RaceResult.new
        r.position = result.place
        r.race_id = y
        r.driver_id = x
        r.save
      end
    end
#    render plain: @allqualiresultsArray #+ @allraceresultsArray
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
      $i +=1  
    end
    
    render plain: @nestedpointsArray
  end
end
