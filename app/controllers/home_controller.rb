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
    
    if [2019].include?(@year.to_i) then 
      #cal_file = open("https://www.f1calendar.com/download/f1-calendar.ics")
      #cal_file = open("https://www.google.com/calendar/ical/lp%40f1-fansite.com/public/basic.ics")
      cal_file = open("https://calendar.google.com/calendar/ical/ekqk1nbdusr1baon1ic42oeeik%40group.calendar.google.com/public/basic.ics")
      cals = Icalendar::Calendar.parse(cal_file)

      cal = cals.first

      @event_data = []
      $i = 0
      while $i < cal.events.length - 1
        if cal.events[$i].dtstart >= Time.now.beginning_of_year then
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
      @event_data.sort_by! { |k| k[:event_quali_start] }
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

    if [2020].include?(@year.to_i) then
      cal_file = URI.open("http://www.formula1.com/calendar/Formula_1_Official_Calendar.ics")
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
    if [2021].include?(@year.to_i) then
      cal_file = URI.open("http://www.formula1.com/calendar/Formula_1_Official_Calendar.ics")
      cals = Icalendar::Calendar.parse(cal_file)
      cal = cals.first

      @event_data = []
      $i = 0
      while $i < cal.events.length
        if cal.events[$i].uid.include? "Qualifying@" then
          if cal.events[$i].status.include? "CONFIRMED" then
            event_uid = cal.events[$i].uid
            event_loc = cal.events[$i].location
            event_status = cal.events[$i].status
            event_summary = cal.events[$i].summary.force_encoding(Encoding::UTF_8) #force encoding to utf-8 to resolve issue due to ical ascii-8 format
            event_quali_start = cal.events[$i].dtstart
            h = {event_uid: event_uid, event_loc: event_loc, event_status: event_status, event_summary: event_summary, event_quali_start: event_quali_start}
            @event_data << h
          end
        end
        $i+=1
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

    if [2022].include?(@year.to_i) then
      # fetch F1 HTML page including list of races
      page = "https://www.formula1.com/en/racing/2022.html"
      doc = Nokogiri::HTML(URI.open(page))
      races = doc.css('.event-list').css('a')
      
      @racePages = []
      races.each do |race|
        # need to compare if race["href"].split("/").last.split(".").first.gsub("_", " ") matches to a race in the DB Races.country where year=2022 then create URL to collect quali_start_tiem   
        if Race.where(year: 2022, country: race["href"].split("/").last.split(".").first.gsub("_", " ")).exists?
          then
            @racePages << "https://www.formula1.com" + race["href"]
        end
      end
      

      # race = doc.css('.event-list').css('a')[7]["href"]

      # scrape each page for quali and race start time
      $i = 0
      while $i < @racePages.length
        page = @racePages[$i]
        begin
          doc = Nokogiri::HTML(URI.open(page))
          rescue Timeout::Error
            puts "The request for a page at #{page} timed out...skipping."
          next
          rescue OpenURI::HTTPError => error
            puts "The request for a page at #{page} returned an error. #{error.message}"
          next
        end
        begin
          start_time_quali=nil
          start_time_quali_local=nil
          start_time_quali_offset=nil
          start_time_quali_local=doc.css('.js-qualifying')[0]["data-start-time"]
          start_time_quali_offset=doc.css('.js-qualifying')[0]["data-gmt-offset"]
          start_time_quali_local.to_datetime
        rescue ArgumentError => error
          puts "the request for race start time for #{race.country} returned an error.  #{error.message}"
        else
          start_time_quali=(start_time_quali_local+start_time_quali_offset).to_datetime
        end
        event_title=doc.css('.f1--s').last.text
        # start_time_race=doc.css('.js-race')[0]["data-start-time"].to_datetime
        # need to commit times to the database against the speficic race
        race = Race.where(year: @year).find_by(race_number: $i+1)
        # race.ical_uid = @event_data[$i][:event_uid]
        race.ical_dtstart = start_time_quali
        race.ical_summary = event_title
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
      x = Driver.find_by!(abbr_name: if result.driver.include?("RAI") then "RÄI" elsif result.driver.include?("MSC") then "SCH" else result.driver end, year: @year).id
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
      x = Driver.find_by!(abbr_name: if result.driver.include?("RAI") then "RÄI" elsif result.driver.include?("MSC") then "SCH" else result.driver end, year: @year).id
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
    doc = Nokogiri::HTML(URI.open(page))
    section=doc.css('.inner-wrap')
    element=section.css('a')
    
    # put element into an array @resultsArray
    @raceArray = []
    $i = 0
    while $i < element.length
      if element[$i]["data-roundtext"].to_s.include?("ROUND") then
        item = element[$i]["href"]
        raceid = element[$i]["data-meetingkey"]
        racecountry = element[$i]["data-racecountryname"]
        racename = element[$i]["href"].split("/").last.split(".").first.gsub("_", " ")
        raceround = element[$i]["data-roundtext"]
        @raceArray << [$i, raceround, item, racename, raceid, racecountry]
      end
      $i +=1
    end
    
    # now fetch qualification and race results for each race and store in @allqualiresultsArray and @allraceresultsArray
    @allqualiresultsArray = []
    @allraceresultsArray = []
    $i = 0
    while $i < @raceArray.length
      @quali_results = QualiResult.joins(:race, :driver)
      
      @racename = @raceArray[$i][3]
      raceid = @raceArray[$i][4]
      @country = @raceArray[$i][5]
      
      page = "https://www.formula1.com/en/results.html/#{@year}/races/#{raceid}/#{@country.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}/qualifying.html"
      
      doc = Nokogiri::HTML(URI.open(page))
      table=doc.css('table.resultsarchive-table')
      rows=table.css('tr')
      
      @qualiresultsArray = []
      $j = 1
      
      while $j < rows.length
        race_country = @racename
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
      doc = Nokogiri::HTML(URI.open(page))   
    
      table=doc.css('table.resultsarchive-table')
      rows=table.css('tr')
    
      @raceresultsArray = []  
      $j = 1
      while $j < rows.length
        race_country = @racename
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
        x = Driver.find_by!(abbr_name: if result.driver.include?("RAI") then "RÄI" elsif result.driver.include?("MSC") then "SCH" else result.driver end, year: @year).id
        y = Race.where("country ILIKE ? AND year = ?", result.race_country, @year).take.id
        r = QualiResult.new
        r.position = result.place
        r.race_id = y
        r.driver_id = x
        r.save
       # if result.place != 0 then
       #   r = QualiResult.find_or_initialize_by(position: result.place, race_id: y)
       #   r.driver_id = x
       #   r.save
       # else
       #   r = QualiResult.find_or_initialize_by(position: result.place, race_id: y, driver_id: x)
       #   # r.position = result.place
       #   # r.race_id = y
       #   r.save
       # end
      end
    end
    
    @allraceresultsArray.each do |race|
      race.each do |result|
        result.race_country
        result.place
        result.car
        result.driver
        result.team
        x = Driver.find_by!(abbr_name: if result.driver.include?("RAI") then "RÄI" elsif result.driver.include?("MSC") then "SCH" else result.driver end, year: @year).id
        y = Race.where("country ILIKE ? AND year = ?", result.race_country, @year).take.id
        r = RaceResult.new
        r.position = result.place
        r.race_id = y
        r.driver_id = x
        r.save
        # if result.place != 0 then
        #   r = RaceResult.find_by( position: result.place, race_id: y)
        #   r.driver_id = x
        #   r.save
        # else
        #   r = RaceResult.find_by(position: result.place, race_id: y, driver_id: x)
        #   # r.position = result.place
        #   # r.race_id = y
        #   r.save
        # end
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
    doc = Nokogiri::HTML(URI.open(page))
    section=doc.css('.inner-wrap')
    element=section.css('a')
    
    # put element into an array @resultsArray (old)
    # @resultsArray = []
    # $i = 0
    # while $i < element.length
    #   item = element[$i]["href"]
    #   @resultsArray << item
    #   $i +=1
    # end

    # put element into an array @resultsArray (updated)
    @resultsArray = []
    $i = 0
    while $i < element.length
      if element[$i]["data-meetingkey"].blank?
      else
        item = element[$i]["href"]
        @resultsArray << item
      end
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
      elsif @year == "2019" then
        seasonstartid = 1000 # first race id for season 2019
      elsif @year == "2020" then
        seasonstartid = 1045 # first race id for season 2020
      elsif @year == "2021" then
        seasonstartid = 1064 # first race id for season 2021
      elsif @year == "2022" then
        seasonstartid = 1124 # first race id for season 2022
      end
      raceid = seasonstartid + $i
      if @country == "United Arab Emerates" then
        @country == "abu-dhabi"
      end
      if @year == "2021" and @country == "Spain" then
        raceid = 1086
      elsif @year == "2021" and @country == "Monaco" then
        raceid = 1067
      end
      page = "https://www.formula1.com/en/results.html/#{@year}/races/#{raceid}/#{@country.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}/qualifying.html"
      doc = Nokogiri::HTML(URI.open(page))   
      
      table=doc.css('table')
      rows=table.css('tr')
      
      @qualiresultsArray = []
      $j = 1
      while $j < rows.length
        race_country = @country
        place = rows[$j].css('td')[1].text
        car = rows[$j].css('td')[2].text
        driver_full_name = rows[$j].css('td')[3].elements[0].text + " " + rows[$j].css('td')[3].elements[1].text
        driver = rows[$j].css('td')[3].elements[2].text
        team = rows[$j].css('td')[4].text
        @qualiresultsArray << Entry.new(race_country, place, car, driver_full_name, driver, team)
        $j +=1
      end
      @allqualiresultsArray << @qualiresultsArray
      
      page = "https://www.formula1.com/en/results.html/#{@year}/races/#{raceid}/#{@country.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}/race-result.html"
      doc = Nokogiri::HTML(URI.open(page))   
    
      table=doc.css('table.resultsarchive-table')
      rows=table.css('tr')
    
      @raceresultsArray = []  
      $j = 1
      while $j < rows.length
        race_country = @country
        place = rows[$j].css('td')[1].text
        car = rows[$j].css('td')[2].text
        driver_full_name = rows[$j].css('td')[3].elements[0].text + " " + rows[$j].css('td')[3].elements[1].text
        driver = rows[$j].css('td')[3].elements[2].text
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
    # using drivers results page - page = "https://www.formula1.com/en/results.html/" + @year + "/drivers.html"
    page = "https://www.formula1.com/en/drivers.html"
    doc = Nokogiri::HTML(URI.open(page))
    driverlist=doc.css('.listing-items--wrapper').css('.col-12')
    # put driverelement into an array @resultsArray
    @driversArray = []
    driverHash = {}
    $i = 0
    while $i < driverlist.length
      driverHash = {driverfirstname: driverlist.css('.listing-item--name')[$i].children[1].text, driverlastname: driverlist.css('.listing-item--name')[$i].children[3].text, drivershortname: driverlist.css('.listing-item--name')[$i].children[3].text.upcase.strip[0..2], driverteam: driverlist.css('.listing-item--team')[$i].text}
      @driversArray << driverHash
      $i +=1
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
    doc = Nokogiri::HTML(URI.open(page))
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
    # page = "https://www.formula1.com/en/championship/races/" + @year.to_s + ".html"
    # doc = Nokogiri::HTML(URI.open(page))
    # section=doc.css('.inner-wrap')
    # element=section.css('a')
    element=Nokogiri::HTML(URI.open("https://www.formula1.com/en/championship/races/" + @year.to_s + ".html")).css('.inner-wrap').css('a')

    if [2018,2019,2020].include?(@year.to_i) then
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
        if @resultsArray[$i].include?("/en/racing/" + @year.to_s + "/") # filter out erroneous entries in the array
          if @resultsArray[$i].exclude?("Pre-Season-Test")
            race = @resultsArray[$i].split("/").last.split(".").first.gsub("_", " ") # gsub replaces underscores with spaces to tidy up
            @raceArray << race
          end
        end
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
  
    if [2021,2022].include?(@year.to_i) then
      $i = 0
      $r = 1
      while $i < element.length
        if element[$i]["data-meetingkey"].blank?
        else
          x = Race.new
          x.year = @year
          x.race_number = $r
          x.country = element[$i]["href"].split("/").last.split(".").first.gsub("_", " ")
          x.save
          $r +=1
        end
          $i +=1
      end
    end
  end
  
  def fetch_track_svg
    require 'nokogiri'
    require 'open-uri'
    @races = Race.where(year: @year)
    @races.each do |race|
      puts "race country #{race.country}"
      if race.country == "United States" then
        page = "https://www.skysports.com/f1/grandprix/" + race.country.downcase.split(" ").join("") + "/circuit-guide"
      elsif race.country == "Abu Dhabi" then
        page = "https://www.skysports.com/f1/grandprix/" + "unitedarabemirates" + "/circuit-guide"
      elsif race.country == "United Arab Emirates" then
        page = "https://www.skysports.com/f1/grandprix/" + "unitedarabemirates" + "/circuit-guide"
      elsif race.country.downcase.split(" ").join("-") == "pre-season-test" then
        page = "https://www.skysports.com/f1/grandprix/" + "unitedarabemirates" + "/circuit-guide"
      elsif race.country == "EmiliaRomagna" then
        page = "https://www.skysports.com/f1/grandprix/" + "emilia-romagna" + "/circuit-guide"
      else
        page = "https://www.skysports.com/f1/grandprix/" + race.country.downcase.split(" ").join("-") + "/circuit-guide"
      end
      # doc = Nokogiri::HTML(URI.open(page))
      begin  
        doc = Nokogiri::HTML(URI.open(page))
        rescue Timeout::Error
          puts "The request for a page at #{page} timed out...skipping."
        next
        rescue OpenURI::HTTPError => error
          puts "The request for a page at #{page} returned an error. #{error.message}"
        next
      end
      #race.img=doc.at_css("path.f1-svg-track__outline").attributes["d"].value
      begin
        race.img=doc.at_css("path.f1-svg-track__outline").attributes["d"].value
      rescue NoMethodError => error
        puts "the request for SVG for track #{race.country} returned an error.  #{error.message}"
      end
      race.save      
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
      x = Driver.find_by!(abbr_name: if result.driver.include?("RAI") then "RÄI" elsif result.driver.include?("MSC") then "SCH" else result.driver end, year: @year).id
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
    doc = Nokogiri::HTML(URI.open(page))
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
