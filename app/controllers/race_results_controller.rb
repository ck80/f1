class RaceResultsController < ApplicationController
  before_action :set_race_result, only: [:show, :edit, :update, :destroy]

  # GET /race_results
  # GET /race_results.json
  def index
    @race_results = RaceResult.joins(:race, :driver).order('race_id ASC, position ASC')
    @quali_results = QualiResult.joins(:race, :driver).order('race_id ASC, position ASC')

  end

  # GET /race_results/1
  # GET /race_results/1.json
  def show
  end

  # GET /race_results/new
  def new
    @race_result = RaceResult.new
  end

  # GET /race_results/1/edit
  def edit
  end

  # POST /race_results
  # POST /race_results.json
  def create
    @race_result = RaceResult.new(race_result_params)

    respond_to do |format|
      if @race_result.save
        format.html { redirect_to @race_result, notice: 'Race result was successfully created.' }
        format.json { render :show, status: :created, location: @race_result }
      else
        format.html { render :new }
        format.json { render json: @race_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /race_results/1
  # PATCH/PUT /race_results/1.json
  def update
    respond_to do |format|
      if @race_result.update(race_result_params)
        format.html { redirect_to @race_result, notice: 'Race result was successfully updated.' }
        format.json { render :show, status: :ok, location: @race_result }
      else
        format.html { render :edit }
        format.json { render json: @race_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /race_results/1
  # DELETE /race_results/1.json
  def destroy
    @race_result.destroy
    respond_to do |format|
      format.html { redirect_to race_results_url, notice: 'Race result was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  class Entry
  	def initialize(place, car, driver, team)
  		@place = place
  		@car = car
      @driver = driver
      @team = team
  	end
  	attr_reader :place
  	attr_reader :car
    attr_reader :driver
    attr_reader :team

  end
  
  def getraceresults
    require 'rubygems'
    require 'nokogiri'
    require 'open-uri'
    
    @race_results = RaceResult.joins(:race, :driver)
    @country = params[:country]
    @year = params[:year]
    seasonstartid = 958 # first race id less 1 to allow for adding raceno to build url
    raceid = seasonstartid + Race.where(country: @country).pluck(:race_number).first
    page = "https://www.formula1.com/en/results.html/#{@year}/races/#{raceid}/#{@country.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}/race-result.html"
    doc = Nokogiri::HTML(open(page))   
    
    table=doc.css('table.resultsarchive-table')
    rows=table.css('tr')
    
    @resultsArray = []
    
    $i = 1
    while $i < rows.length
      place = rows[$i].css('td')[1].text
      car = rows[$i].css('td')[2].text
      driver = rows[$i].css('td')[3].text.split.last
      team = rows[$i].css('td')[4].text
      @resultsArray << Entry.new(place, car, driver, team)
      $i +=1
    end
    #render plain: @resultsArray
    render template: 'race_results/getraceresults'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_race_result
      @race_result = RaceResult.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def race_result_params
      params.require(:race_result).permit(:position)
    end
end
