class Point < ApplicationRecord
    validates :item, :points, presence: true
    validates :item, uniqueness: true
end
