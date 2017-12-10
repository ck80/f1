class RaceResult < ApplicationRecord
  belongs_to :race
  belongs_to :driver
  validates :position, :race_id, :driver_id, presence: true
  validates :position, uniqueness: { scope: [:race_id, :driver_id], message: ": you already have an entry for this race, please edit the existing tip instread of create a new one." }
end
