module Api
  module V1
    class LineFoodsController < ApplicationController
      before_action :set_food, only: %i[create replace]

      def index
        line_foods = LineFood.active
        if line_foods.exists?
          render json: {
            line_food_ids: line_foods.map { |line_food| line_food.id },
            restaurant: line_food[0].restaurant, # 0番目であることには関係ない
            count: line_foods.sum { |line_food| line_food[:count] },
            amount: line_foods.sum { |line_food| line_food.total_amount }
          }, status: :ok # 200 ok
        else
          # MEMO: 一つも仮注文がない場合、リクエストは成功したが返すコンテンツが無いことを明示的に示す
          render json: {}, status: :no_content # 204 No Content
        end
      end

      def create
        # 仕様： 他店舗での商品が存在する場合は、早期リターン
        # MEMO: LineFoodモデルクラスのactive
        if LineFood.active.other_restaurant(@ordered_food.restaurant.id).exists?
          # if LineFood.where(active: true).where.not(restaurant_id: @ordered_food.restaurant.id).exists?
          return render json: {
            # MEMO: first であることに深い意味はなく、どれを取ってきても同じなので,first
            existing_restaurant: LineFood.other_restaurant(@ordered_food.restaurant.id).first.restaurant.name,
            new_restaurant: Food.find(params[:food_id]).restaurant.name
          }, status: :not_acceptable # 406 Not Acceptable
        end

        set_line_food(@ordered_food)

        if @line_food.save # MEMO:line_foodインスタンスの保存と保存判定を同時に行う
          render json: {
            line_food: @line_food
          }, status: :created # 201 Created
        else
          render json: {}, status: :internal_server_error # 500 Internal Server Error
        end
      end

      # 既に存在する仮注文を論理削除するためのもの（activeカラムを非活性化する）
      def replace
        LineFood.active.other_restaurant(@ordered_food.restaurant.id).each do |line_food|
          line_food.update_attribute(:active, false) # update_attribute は、save もする
        end

        set_line_food(@ordered_food)

        if @line_food.save
          render json: {
            line_food: @line_food
          }, status: :created # 201 Created
        else
          render json: {}, status: :internal_server_error # 500 Internal Server Error
        end
      end

      private

      def set_food
        @ordered_food = Food.find(params[:food_id])
      end

      # 仕様: line_food インスタンスの生成、数量更新のみ。このメソッドでは保存はしない。
      def set_line_food(ordered_food)
        if ordered_food.line_food.present?
          @line_food = ordered_food.line_food # order_foodは foodインスタンス
          @line_food.attributes = {
            count: ordered_food.line_food + params[:count],
            active: true # TODO：active は元々true だから更新しなくていいと感じたけど、false であるときもある？
          }
        else
          # MEMO:　ordered_food.line_food.build() でも動きそうだが、リレーションを明確にしている
          #       ordered_food に対して一つの line_food インスタンスを作成することを意図
          @line_food = ordered_food.build_line_food(
            count: params[:count],
            active: true,
            restaurant: ordered_food.restaurant
            # MEMO:line_food インスタンスを作成する際に、親である restaurant と、line_food 自体の属性（count や active）を同時に指定することには、違和感
          )
        end
      end
    end
  end
end
