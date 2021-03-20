class QualiResultsController < ApplicationController
  before_action :set_quali_result, only: [:show, :edit, :update, :destroy]

  # GET /quali_results
  # GET /quali_results.json
  def index
    @quali_results = QualiResult.joins(:race, :driver)
  end

  # GET /quali_results/1
  # GET /quali_results/1.json
  def show
  end

  # GET /quali_results/new
  def new
    @quali_result = QualiResult.new
  end

  # GET /race_results/1/edit
  def edit
  end

  # POST /race_results
  # POST /race_results.json
  def create
    @quali_result = QualiResult.new(quali_result_params)

    respond_to do |format|
      if @quali_result.save
        format.html { redirect_to @quali_result, notice: 'Quali result was successfully created.' }
        format.json { render :show, status: :created, location: @quali_result }
      else
        format.html { render :new }
        format.json { render json: @quali_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quali_results/1
  # PATCH/PUT /quali_results/1.json
  def update
    respond_to do |format|
      if @aquali_result.update(quali_result_params)
        format.html { redirect_to @quali_result, notice: 'Quali result was successfully updated.' }
        format.json { render :show, status: :ok, location: @quali_result }
      else
        format.html { render :edit }
        format.json { render json: @quali_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quali_results/1
  # DELETE /quali_results/1.json
  def destroy
    @quali_result.destroy
    respond_to do |format|
      format.html { redirect_to quali_results_url, notice: 'Quali result was successfully destroyed.' }
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
  
  def getqualiresults
    require 'rubygems'
    require 'nokogiri'
    require 'open-uri'
    
    @quali_results = QualiResult.joins(:race, :driver)
    @country = params[:country]
    @year = params[:year]
    seasonstartid = 958 # first race id less 1 to allow for adding raceno to build url
    raceid = seasonstartid + Race.where(country: @country).pluck(:race_number).first
    page = "https://www.formula1.com/en/results.html/#{@year}/races/#{raceid}/#{@country.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}/qualifying.html"
    doc = Nokogiri::HTML(URI.open(page))   
    
    table=doc.css('table.resultsarchive-table')
    rows=table.css('tr')
    
    @qualiresultsArray = []
    
    $i = 1
    while $i < rows.length
      place = rows[$i].css('td')[1].text
      car = rows[$i].css('td')[2].text
      driver = rows[$i].css('td')[3].text.split.last
      team = rows[$i].css('td')[4].text
      @qualiresultsArray << Entry.new(place, car, driver, team)
      $i +=1
    end
    #render plain: @resultsArray
    render template: 'quali_results/getqualiresults'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quali_result
      @quali_result = QualiResult.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quali_result_params
      params.require(:quali_result).permit(:position)
    end
end
