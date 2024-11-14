3.times do |n|
  restaurant = Restaurant.new(
    name: "testレストラン_#{n}",
    fee: 200,
    time_required: 15,
  )

  12.times do |m|
    restaurant.foods.build(
      name: "フード名_#{m}",
      price: 700,
      description: "フード_#{m}の説明文だよお"
    )
  end

  restaurant.save!
end
