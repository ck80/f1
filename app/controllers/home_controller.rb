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
    

    #look for tip qual_first abbr_name
    #a = Tip.find_by(user_id: 6, race_id: 1).qual_first
    #look for position in quali_results
    #b = RaceResult.find_by(race_id: 1, driver_id: (Driver.find_by(abbr_name: a).id)).position
    @points = []
    @tips.each do |tip|
      q1st_points = Point.find_by(item: "q1st").points - RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by!(abbr_name: (tip.qual_first)).id)).position
      q2nd_points = Point.find_by(item: "q2nd").points - RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by!(abbr_name: (tip.qual_second)).id)).position
      q3rd_points = Point.find_by(item: "q3rd").points - RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by!(abbr_name: (tip.qual_third)).id)).position
      r1st_points = Point.find_by(item: "r1st").points - RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by!(abbr_name: (tip.race_first)).id)).position
      r2nd_points = Point.find_by(item: "r2nd").points - RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by!(abbr_name: (tip.race_second)).id)).position
      r3rd_points = Point.find_by(item: "r3rd").points - RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by!(abbr_name: (tip.race_third)).id)).position
      r10th_points = Point.find_by(item: "r10th").points - RaceResult.find_by(race_id: (tip.race_id), driver_id: (Driver.find_by!(abbr_name: (tip.race_tenth)).id)).position
      total_points = q1st_points + q2nd_points + q3rd_points + r1st_points + r2nd_points + r3rd_points + r10th_points
      @points << total_points       
    end
    
    #RaceResult.find_by(race_id: 1, driver_id: (Driver.find_by(abbr_name: (Tip.find_by(user_id: 6, race_id: 1).qual_first)).id)).position
    
    #lookup points
    #c = Point.find_by(item: "q1st").points
    #calculate points
    #d = c - b
    
    
    render plain: @points
  end
end
