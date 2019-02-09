class HomeController < ApplicationController
  before_action :get_year

  def get_year
    if params[:year].present? then
      @year = params[:year].to_s
    else
      @year = Time.current.year.to_s
    end
  end

  def index
    if params[:approved] == "false"
      @users = User.where(approved: false)
    else
      @users = User.all
    end
  end
  
  def test
  end

  def show
    @users = User.all
  end
  
  class Entry
    def initialize(race_country, place, car, driver_full_name, driver, team)
      @race_country = race_country
      @place = place
      @car = car
      @driver_full_name = driver_full_name
      @driver = driver
      @team = team
    end
    attr_reader :race_country
    attr_reader :place
    attr_reader :car
    attr_reader :driver_full_name
    attr_reader :driver
    attr_reader :team
  end

  class ForgottenTip
  	def initialize(race_country, user_name, race_lowest_points)
  		@race_country = race_country
      @user_name = user_name
      @race_lowest_points = race_lowest_points
  	end
    attr_reader :race_country
    attr_reader :user_name
    attr_reader :race_lowest_points
  end
  
  def update_race_start
    # load HTML parser
    require 'rubygems'
    require 'open-uri'

    # load ical parser
    require 'icalendar'
    
    if [2017,2018].include?(@year) then 
      cal_file = open("https://www.formula1.com/sp/static/f1/" + @year.to_s + "/calendar/ical.ics") 
      cals = Icalendar::Calendar.parse(cal_file)
      cal = cals.first
      
      @event_data = []
      $i = 3
      while $i < cal.events.length
        event_uid = cal.events[$i].uid
        event_summary = cal.events[$i].summary.force_encoding(Encoding::UTF_8) #force encoding to utf-8 to resolve issue due to ical ascii-8 format
        event_quali_start = cal.events[$i].dtstart
        h = {event_uid: event_uid, event_summary: event_summary, event_quali_start: event_quali_start}
        @event_data << h
        $i +=5
      end
  
      $i=0
      while $i < @event_data.length
        race = Race.where(year: @year).find_by(race_number: $i+1)
        race.ical_uid = @event_data[$i][:event_uid]
        race.ical_dtstart = @event_data[$i][:event_quali_start].to_datetime
        race.ical_summary = @event_data[$i][:event_summary]
        race.save
        $i+=1
      end
    end
    
    if [2019].include?(@year) then 
      #cal_file = open("https://www.f1calendar.com/download/f1-calendar.ics")
      #cal_file = open("https://www.google.com/calendar/ical/lp%40f1-fansite.com/public/basic.ics")
      cal_file = open("https://calendar.google.com/calendar/ical/ekqk1nbdusr1baon1ic42oeeik%40group.calendar.google.com/public/basic.ics")
      cals = Icalendar::Calendar.parse(cal_file)

      cal = cals.first

      @event_data = []
      $i = 0
      while $i < cal.events.length - 1
        if cal.events[$i].dtstart >= Time.now then
          if cal.events[$i].summary.include? "qualifying" then
            event_uid = cal.events[$i].uid
            event_summary = cal.events[$i].summary.force_encoding(Encoding::UTF_8) #force encoding to utf-8 to resolve issue due to ical ascii-8 format
            event_quali_start = cal.events[$i].dtstart
            h = {event_uid: event_uid, event_summary: event_summary, event_quali_start: event_quali_start}
            @event_data << h
          end
        end
        $i +=1
      end
      @event_data.sort_by! { |k| k["event_quali_start"] }.reverse!
      $i=0
      while $i < @event_data.length
        race = Race.where(year: @year).find_by(race_number: $i+1)
        race.ical_uid = @event_data[$i][:event_uid]
        race.ical_dtstart = @event_data[$i][:event_quali_start].to_datetime
        race.ical_summary = @event_data[$i][:event_summary]
        race.save
        $i+=1
      end
    end
  end
  
  def update_race_tip_points_forgotten_entries
    # this function is still WORK IN PROGRESS
    
    # get all the users
    @users=User.where(approved: true)
    
    # get all the races
    @races = Race.where(year: 2018) 
    
    # create array to store results
    @resultsArray = []

    # for each race check there is an entry for each user, record which users don't have tips
    @races.each do |race|
      # for each race, get lowest points
      @race_lowest_points = Tip.where(race_id: race.id).order(race_total_points: :DESC).first.race_total_points
      @users.each do |user|
        if race.tips.where(user_id: user.id).exists? then
        else
          @resultsArray << ForgottenTip.new(race.country, user.name, @race_lowest_points)
        end          
      end

      
    end

    


  end

  
  def update_race_tip_points
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
    
    #render plain: @nestedpointsArray.join("\n")
    
  end

  # work in progress - use Ergast API for results

  def fetch_last_quali_results_ergast_api
    # load HTML parser
    # require 'rubygems'
    # require 'nokogiri'
    require 'open-uri'

    @last_quali_round = Race.where("ical_dtstart <= ?", Time.now + 1.day + 3.hours).order(ical_dtstart: :asc).last.race_number.to_s
    ergestapi = "https://ergast.com/api/f1/" + @year.to_s + "/" + @last_quali_round.to_s + "/qualifying.json"
    # xml_doc = Nokogiri::XML.parse(open(ergestapi))
    json_doc = JSON.parse(open(ergestapi).read)

    @resultsArray = []

    json_doc["MRData"]["RaceTable"]["Races"].first["QualifyingResults"].each do |r|
      race_country = json_doc["MRData"]["RaceTable"]["Races"].first["Circuit"]["Location"]["country"]
      place = r["position"]
      car = r["number"]
      driver_full_name = r["Driver"]["givenName"] + " " + r["Driver"]["familyName"]
      driver = r["Driver"]["code"]
      team = r["Constructor"]["name"]
      @resultsArray << Entry.new(race_country, place, car, driver_full_name, driver, team)
    end

    # commit results to DB
    @resultsArray.each do |result|
      result.race_country
      result.place
      result.car
      result.driver
      result.team
      x = Driver.find_by!(abbr_name: result.driver, year: @year).id
      y = Race.where("country ILIKE ? AND year = ?", result.race_country, @year).take.id
      r = QualiResult.new
      r.position = result.place
      r.race_id = y
      r.driver_id = x
      r.save
    end

  end

  def fetch_last_race_results_ergast_api
    # load HTML parser
    # require 'rubygems'
    # require 'nokogiri'
    require 'open-uri'

    @last_race_round = Race.where("ical_dtstart <= ?", Time.now + 1.day + 3.hours).order(ical_dtstart: :asc).last.race_number.to_s
    ergestapi = "https://ergast.com/api/f1/" + @year.to_s + "/" + @last_race_round.to_s + "/results.json"
    # xml_doc = Nokogiri::XML.parse(open(ergestapi))
    json_doc = JSON.parse(open(ergestapi).read)

    @resultsArray = []

    json_doc["MRData"]["RaceTable"]["Races"].first["Results"].each do |r|
      race_country = json_doc["MRData"]["RaceTable"]["Races"].first["Circuit"]["Location"]["country"]
      place = r["position"]
      car = r["number"]
      driver_full_name = r["Driver"]["givenName"] + " " + r["Driver"]["familyName"]
      driver = r["Driver"]["code"]
      team = r["Constructor"]["name"]
      @resultsArray << Entry.new(race_country, place, car, driver_full_name, driver, team)
    end

    # commit results to DB
    @resultsArray.each do |result|
      result.race_country
      result.place
      result.car
      result.driver
      result.team
      x = Driver.find_by!(abbr_name: result.driver, year: @year).id
      y = Race.where("country ILIKE ? AND year = ?", result.race_country, @year).take.id
      r = RaceResult.new
      r.position = result.place
      r.race_id = y
      r.driver_id = x
      r.save
    end

  end

  def fetch_results_action
    # load HTML parser
    require 'rubygems'
    require 'nokogiri'
    require 'open-uri'
    
    # fetch F1 HTML page including list of races
    page = "https://www.formula1.com/en/championship/races/" + @year.to_s + ".html"
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
    while $i < @resultsArray.length 
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
      if @year == "2017" then
        seasonstartid = 959 # first race id for season 2017
      elsif @year == "2018" then
        seasonstartid = 979 # first race id for season 2018
      end
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
        driver_full_name = rows[$j].css('td')[3].css('span')[0].text + " " + rows[$j].css('td')[3].css('span')[1].text          
        driver = rows[$j].css('td')[3].text.split.last
        team = rows[$j].css('td')[4].text
        @qualiresultsArray << Entry.new(race_country, place, car, driver_full_name, driver, team)
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
        driver_full_name = rows[$j].css('td')[3].css('span')[0].text + " " + rows[$j].css('td')[3].css('span')[1].text
        driver = rows[$j].css('td')[3].text.split.last
        team = rows[$j].css('td')[4].text
        @raceresultsArray << Entry.new(race_country, place, car, driver_full_name, driver, team)
        $j +=1
      end
      @allraceresultsArray << @raceresultsArray  
      $i +=1
    end
    
    # render plain: @allqualiresultsArray 
    
    # commit results to DB
    @allqualiresultsArray.each do |race|
      race.each do |result|
        result.race_country
        result.place
        result.car
        result.driver
        result.team
        x = Driver.find_by!(abbr_name: result.driver, year: @year).id
        y = Race.where("country ILIKE ? AND year = ?", result.race_country, @year).take.id
        r = QualiResult.new
        r.position = result.place
        r.race_id = y
        r.driver_id = x
        r.save
#        if result.place != 0 then
#          r = QualiResult.find_or_initialize_by(position: result.place, race_id: y)
#          r.driver_id = x
#          r.save
#        else
#          r = QualiResult.find_or_initialize_by(position: result.place, race_id: y, driver_id: x)
#          # r.position = result.place
#          # r.race_id = y
#          r.save
#        end
      end
    end
    
    @allraceresultsArray.each do |race|
      race.each do |result|
        result.race_country
        result.place
        result.car
        result.driver
        result.team
        x = Driver.find_by!(abbr_name: result.driver, year: @year).id
        y = Race.where("country ILIKE ? AND year = ?", result.race_country, @year).take.id
        r = RaceResult.new
        r.position = result.place
        r.race_id = y
        r.driver_id = x
        r.save
#        if result.place != 0 then
#          r = RaceResult.find_by( position: result.place, race_id: y)
#          r.driver_id = x
#          r.save
#        else
#          r = RaceResult.find_by(position: result.place, race_id: y, driver_id: x)
#          # r.position = result.place
#          # r.race_id = y
#          r.save
#        end
      end
    end
    # render plain: @allqualiresultsArray #+ @allraceresultsArray
  end


  def fetch_drivers_by_races
    ## added this function to ensure drivers not listed on drivers URL are added to Driver table
    ## by scanning for all drivers in qualies and in races and adding them to the table

    # load HTML parser
    require 'rubygems'
    require 'nokogiri'
    require 'open-uri'
    
    # fetch F1 HTML page including list of races
    page = "https://www.formula1.com/en/championship/races/" + @year + ".html"
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
      if @year == "2017" then
        seasonstartid = 959 # first race id for season 2017
      elsif @year == "2018" then
        seasonstartid = 979 # first race id for season 2018
      elsif @year == "2019" then
        seasonstartid = 1000 # first race id for season 2019
      end
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
        driver_full_name = rows[$j].css('td')[3].css('span')[0].text + " " + rows[$j].css('td')[3].css('span')[1].text          
        driver = rows[$j].css('td')[3].text.split.last
        team = rows[$j].css('td')[4].text
        @qualiresultsArray << Entry.new(race_country, place, car, driver_full_name, driver, team)
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
        driver_full_name = rows[$j].css('td')[3].css('span')[0].text + " " + rows[$j].css('td')[3].css('span')[1].text
        driver = rows[$j].css('td')[3].text.split.last
        team = rows[$j].css('td')[4].text
        @raceresultsArray << Entry.new(race_country, place, car, driver_full_name, driver, team)
        $j +=1
      end
      @allraceresultsArray << @raceresultsArray  
      $i +=1
    end

    # commit results to DB
    @allqualiresultsArray.each do |race|
      race.each do |result|
        d = Driver.new
        d.year = @year
        d.name = result.driver_full_name
        d.abbr_name = result.driver
        d.team = result.team
        d.save
      end
    end
  
    @allraceresultsArray.each do |race|
      race.each do |result|
        d = Driver.new
        d.year = @year
        d.name = result.driver_full_name
        d.abbr_name = result.driver
        d.team = result.team
        d.save
      end
    end
  # render plain: @allqualiresultsArray #+ @allraceresultsArray
  end

  def fetch_drivers
    # load HTML parser
    require 'rubygems'
    require 'nokogiri'
    require 'open-uri'
    
    # fetch F1 HTML page including list of races
    page = "https://www.formula1.com/en/results.html/" + @year + "/drivers.html"
    doc = Nokogiri::HTML(open(page))
    section=doc.css('.table-wrap')
    teamelement=section.css('a')
    
    # put driverelement into an array @resultsArray
    @driversArray = []
    driverHash = {}
    $i = 0
    while $i < teamelement.length
      if $i.even?
        driverHash = {driverfirstname: teamelement[$i].css('span')[0].text, driverlastname: teamelement[$i].css('span')[1].text, drivershortname: teamelement[$i].css('span')[2].text, driverteam: teamelement[$i+1].text}
      end
      @driversArray << driverHash
      $i +=2
    end

    @driversArray.each do |driver|
      x = Driver.new
      x.year = @year
      x.name = driver[:driverfirstname] + " " + driver[:driverlastname]
      x.abbr_name = driver[:drivershortname]
      x.team = driver[:driverteam]
      x.save
    end

  end

  def fetch_drivers_by_championship
    # load HTML parser
    require 'rubygems'
    require 'nokogiri'
    require 'open-uri'
    
    # fetch F1 HTML page including list of races
    page = "https://www.formula1.com/en/championship/drivers.html"
    doc = Nokogiri::HTML(open(page))
    section=doc.css('figcaption')
    driverelement=section.css('h1')
    teamelement=section.css('p')
    
    # put driverelement into an array @resultsArray
    @driversArray = []
    driverHash = {}
    $i = 0
    while $i < driverelement.length
      driverHash = {drivername: driverelement[$i].text, driverteam: teamelement[$i].text.split.join(" ") }
      x = Driver.new
      x.year = @year
      x.name = driverHash[:drivername]
      x.abbr_name = (x.name.split.second + if x.name.split.third.nil? then "" else x.name.split.third end)[0..2].upcase
      x.team = driverHash[:driverteam]
      x.save
      $i +=1
    end

  end

  def fetch_races
    # load HTML parser
    require 'rubygems'
    require 'nokogiri'
    require 'open-uri'
    
    # fetch F1 HTML page including list of races
    page = "https://www.formula1.com/en/championship/races/" + @year + ".html"
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
    while $i < @resultsArray.length-(if @year == "2017" then 2 elsif @year == "2018" then 1 elsif @year =="2019" then 0 end) # drop non-race elements to clean up array
      race = @resultsArray[$i].split("/").last.split(".").first.gsub("_", " ") # gsub replaces underscores with spaces to tidy up
      @raceArray << race
      $i +=1
    end

    $i = 1
    @raceArray.each do |race|
      x = Race.new
      x.year = @year
      x.race_number = $i
      x.country = race
      x.save
      $i +=1
    end

  end

  def fetch_races_ergast_api
    require 'open-uri'

    @last_quali_round = Race.where("ical_dtstart <= ?", Time.now + 1.day + 3.hours).order(ical_dtstart: :asc).last.race_number.to_s
    ergestapi = "https://ergast.com/api/f1/" + @year.to_s + ".json"
    # xml_doc = Nokogiri::XML.parse(open(ergestapi))
    json_doc = JSON.parse(open(ergestapi).read)

    @resultsArray = []

    json_doc["MRData"]["RaceTable"]["Races"].first["QualifyingResults"].each do |r|
      race_country = json_doc["MRData"]["RaceTable"]["Races"].first["Circuit"]["Location"]["country"]
      place = r["position"]
      car = r["number"]
      driver_full_name = r["Driver"]["givenName"] + " " + r["Driver"]["familyName"]
      driver = r["Driver"]["code"]
      team = r["Constructor"]["name"]
      @resultsArray << Entry.new(race_country, place, car, driver_full_name, driver, team)
    end

    # commit results to DB
    @resultsArray.each do |result|
      result.race_country
      result.place
      result.car
      result.driver
      result.team
      x = Driver.find_by!(abbr_name: result.driver, year: @year).id
      y = Race.where("country ILIKE ? AND year = ?", result.race_country, @year).take.id
      r = QualiResult.new
      r.position = result.place
      r.race_id = y
      r.driver_id = x
      r.save
    end

    ### RACES FROM HERE ###

    # fetch F1 HTML page including list of races
    page = "https://www.formula1.com/en/championship/races/" + @year + ".html"
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
    while $i < @resultsArray.length-(if @year == "2017" then 2 elsif @year == "2018" then 1 elsif @year == "2019" then 0 end) # drop non-race elements to clean up array
      race = @resultsArray[$i].split("/").last.split(".").first.gsub("_", " ") # gsub replaces underscores with spaces to tidy up
      @raceArray << race
      $i +=1
    end

    $i = 1
    @raceArray.each do |race|
      x = Race.new
      x.year = @year
      x.race_number = $i
      x.country = race
      x.save
      $i +=1
    end

  end

  def account_upgrade
    u = User.find_by(name: current_user.name)
    u.admin = true
    u.save
  end

  def update_points_table
    ## set up points table

    # q1st points
    p = Point.new
    p.item = "q1st"
    p.points = 5
    p.save
    
    # q2nd points
    p = Point.new
    p.item = "q2nd"
    p.points = 3
    p.save

    # q3rd points
    p = Point.new
    p.item = "q3rd"
    p.points = 1
    p.save

    # r1st points
    p = Point.new
    p.item = "r1st"
    p.points = 25
    p.save

    # r2nd points
    p = Point.new
    p.item = "r2nd"
    p.points = 18
    p.save

    # r3rd points
    p = Point.new
    p.item = "r3rd"
    p.points = 15
    p.save

    # r4th points
    p = Point.new
    p.item = "r4th"
    p.points = 12
    p.save

    # r5th points
    p = Point.new
    p.item = "r5th"
    p.points = 10
    p.save

    # r5th points
    p = Point.new
    p.item = "r5th"
    p.points = 10
    p.save

    # r6th points
    p = Point.new
    p.item = "r6th"
    p.points = 8
    p.save

    # r7th points
    p = Point.new
    p.item = "r7th"
    p.points = 6
    p.save

    # r8th points
    p = Point.new
    p.item = "r8th"
    p.points = 4
    p.save

    # r9th points
    p = Point.new
    p.item = "r9th"
    p.points = 2
    p.save

    # r10th points
    p = Point.new
    p.item = "r10th"
    p.points = 1
    p.save
  
    # r10th_bonus points
    p = Point.new
    p.item = "r10th_bonus"
    p.points = 15
    p.save

  end

end
