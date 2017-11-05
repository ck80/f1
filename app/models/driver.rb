class Driver < ApplicationRecord
  has_many :race_results
  has_many :quali_results
end
