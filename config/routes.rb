Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resorces :restaurants do
        resorces :food, only: %i[index]
      end
      resorces :line_food, only: %i[index create]
      put 'line_foods/replace', to: 'line_foods#replace' # garape-gem の put-end ブロック putで叩かれたときに呼ばれる
      resorces :orders, only: %i[create]
    end
  end
end
