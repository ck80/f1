class Race < ApplicationRecord
  has_many :tips, dependent: :destroy
  has_many :race_results, dependent: :destroy
  has_many :quali_results, dependent: :destroy
  validates :year, :country, :race_number, presence: true
  validates :country, uniqueness: { scope: :year, message: "should have only one entry per year" }
end
