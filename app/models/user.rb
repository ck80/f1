class User < ApplicationRecord
  has_many :leaderboards
  has_many :tips
end
