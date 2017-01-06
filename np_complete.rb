require 'pp'
require_relative 'lib/amb.rb'

total = 1505
menu = {
  "Mixed Fruit"       => 215,
  "French Fries"      => 275,
  "Side Salad"        => 335,
  "Hot Wings"         => 355,
  "Mozzarella Sticks" => 420,
  "Sampler Plate"     => 580
}

solutions = 0
order = {}

Ambigious.solve_all do |amb|

  menu.each do |label, price|
    max_amount = total / price
    amount = amb.choose(0..max_amount)
    order[label] = [price, amount]
  end

  current_total = order.inject(0) do |sum, (_, (price, amount))|
    sum += price * amount
  end
  amb.assert total == current_total

  solutions += 1
  puts
  order.each do |label, (price, amount)|
    next if amount == 0
    puts "%dx %s (%.2f)" % [amount, label, price / 100.0]
  end
  puts "Branches explored: #{amb.branches_count}"
end

puts
puts "#{solutions} possible orders found"

