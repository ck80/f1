class Race < ApplicationRecord
  has_many :tips
  has_many :race_results
  has_many :quali_results
end
