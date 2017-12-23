class Race < ApplicationRecord
  has_many :tips
  has_many :race_results
  has_many :quali_results
  validates :year, :country, :race_number, presence: true
  validates :country, uniqueness: { scope: :year, message: "should have only one entry per year" }
end
