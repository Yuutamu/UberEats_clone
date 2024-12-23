# MEMO: 仮注文データはあくまで商品と1:1の関係。その商品がいくつか？という情報しか持たない
# MEMO: orderが確定するまではline_foodsレコードはorderのことを知らないので, nullを許容

class CreateLineFoods < ActiveRecord::Migration[6.1]
  def change
    create_table :line_foods do |t|
      t.references :food, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.references :order, foreign_key: true
      t.integer :count, null: false, default: 0
      t.boolean :active, null: false, default: false

      t.timestamps
    end
  end
end
