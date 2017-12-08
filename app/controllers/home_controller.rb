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
  
  def action
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
    render plain: @allqualiresultsArray + @allraceresultsArray
  end
end
