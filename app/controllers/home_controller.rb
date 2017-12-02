class HomeController < ApplicationController
  def index
    @users = User.all
#    render plain: @user.count

  require 'rubygems'
  require 'nokogiri'
  require 'open-uri'

  page = "https://www.formula1.com/en/championship/races/2017.html"
  doc = Nokogiri::HTML(open(page))
  table=doc.css('.inner-wrap')
  rows=table.css('a')

  @resultsArray = []
  $i = 0
  while $i < rows.length
    race = rows[$i]["href"]
    @resultsArray << race
    $i +=1
  end
  render plain: @resultsArray[0..rows.length]  
  end
  
  
end
