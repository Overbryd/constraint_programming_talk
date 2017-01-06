require 'terminal-table'
require_relative 'lib/amb.rb'

class Array
  def uniq?
    all? { |e| rindex(e) == index(e) }
  end
end

# Taken from: http://www.math.unipd.it/~frossi/cp-school/CPschool05notes.pdf
#
# A typical way how to model this problem
# is to assume that each queen is in a different column
# and to assign a variable Ri (with the domain 1...N)
# to the queen in the i-th column indicating
# the position of the queen in the row.

class NQueens < Struct.new(:n)
  include Amb

  def values
    rows = []

    (0...n).each do |row|
      col = choose(0...n)
      rows[row] = col
    end
    assert rows.uniq?

    positive_slope = []
    negative_slope = []
    rows.each_with_index.map do |col, i|
      positive = col + n-1 - i
      positive_slope << positive
      negative = col - n-1 + i
      negative_slope << negative
    end
    assert positive_slope.uniq?
    assert negative_slope.uniq?

    rows
  end

  def to_s(rows = values)
    puts "Branches explored: #{branches_count}"
    Terminal::Table.new do |table|
      table << [' ', *(0...n).to_a]
      table << :separator
      (0...n).each do |row|
        table << [row, *(0...n).map { |col| rows[col] == row ? '♛' : ' ' }]
        table << :separator if row < n - 1
      end
    end.to_s
  end
end

n = ARGV.first.to_i
n = n > 0 ? n : 8
puts NQueens.new(n)
