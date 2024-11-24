class Order < ApplicationRecord
  has_many :line_foods

  validates :total_price, numericality: { greater_than: 0 }

  def save_with_update_line_foods!(line_foods)
    # MEMO: block内すべてが成功した場合に変更がDBに保存される | エラー発生時は変更をロールバックする
    # MEMO: 例外発生時、ActiveRecord::Rollback 例外エラーを返す
    ActiveRecord::Base.transaction do
      line_foods.each do |line_food|
        line_food.update!(active: false, order: self) # MEMO: order属性を現在の Orderインスタンス（self）に設定
      end
      save!
    end
  end
end
