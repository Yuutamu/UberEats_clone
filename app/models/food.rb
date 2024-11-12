class Food < ApplicationRecord
  belongs_to :restaurant
  belongs_to :orders, optional: true
  has_one :line_food
end
