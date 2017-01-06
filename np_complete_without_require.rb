require "continuation"

def failure
  @backtrack.pop.call
end

def choose(enum)
  @backtrack ||= [-> {raise "exhausted"}]
  enum.each do |choice|
    callcc do |callsite|
      @backtrack << callsite
      return choice
    end
  end
  failure
end

total = 1505
menu = {
  "Mixed Fruit" => 215, "French Fries" => 275,
  "Side Salad" => 335, "Hot Wings" => 355,
  "Mozzarella Sticks" => 420, "Sampler Plate" => 580
}

order = {}
menu.each do |_, price|
  amount_per_item = choose(0..10)
  order[price] = amount_per_item
end

current_total = order.inject(0) do |sum, (price, amount)|
  sum += price * amount
end
failure unless current_total == total

menu.map { |label, price| puts "%s: %s" % [label, order[price]] if order[price] > 0 }