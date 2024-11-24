# 仕様 : Orderは、どの店舗に何円を支払うかしかデータを管理しない
module Api
  module V1
    class OrdersController < ApplicationController
      def create
        # line_food_ids をparams で取れていることに違和感を感じる Json の要素名では？
        posted_line_foods = LineFood.where(id: params[:line_food_ids])
        order = Order.new(
          total_price(posted_line_foods)
        )
        if order.save_with_update_line_foods!(posted_line_foods)
          render json: {}, status: :no_content
        else
          render json: {}, status: :internal_server_error
        end
      end

      private

      def total_price(posted_line_foods)
        posted_line_foods.sum { |line_food|
          line_food.total_amount
        } + posted_line_foods.first.restaurant.fee # first でなくとも良い
      end
    end
  end
end
