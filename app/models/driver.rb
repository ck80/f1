class Driver < ApplicationRecord
  has_many :race_results, dependent: :destroy
  has_many :quali_results, dependent: :destroy
  validates :year, :name, :abbr_name, :team, presence: true
  validates :abbr_name, uniqueness: { scope: :year, message: "should have only one entry per year" }
end
