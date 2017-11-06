class Tip < ApplicationRecord
  belongs_to :user
  belongs_to :race
  validates_associated :user
  validates_associated :race
  validates :qual_first, :qual_second, :qual_third, :race_first, :race_second, :race_third, :race_tenth, presence: true
  validates :race_id, uniqueness: { scope: :user_id, message: "should have once per user_id" }
  validates :race_id, uniqueness: { scope: :year, message: "should have once per year" }  
end
