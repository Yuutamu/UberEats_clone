class LineFood < ApplicationRecord
  belongs_to :food
  belongs_to :restaurant
  belongs_to :order, optional: true

  validates :count, numericality: { greater_than: 0 }

  # MEMO: 仮注文 有効であるレコードを返す
  scope :active, -> { where(active: true) }
  # MEMO: 他の店舗のLineFoodのレコードを返す（picked_restaurant_idは、スコープを呼び出す際に指定した値に基づいて動的に変わる変数）
  scope :other_restaurant, ->(picked_restaurant_id) { where.not(restaurant_id: picked_restaurant_id) }

  def total_amount
    food.price * count
  end
end
