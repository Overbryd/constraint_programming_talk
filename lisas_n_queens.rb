# (c) Lisa
require 'pp'

class Placement
  def inspect
    ' '
  end
end

class Queen < Placement
  def inspect
    'Q'
  end
end

$branches_count = 0

Q = Queen.new

class Array
  def uniq?
    all? { |e| index(e) == rindex(e) }
  end

  def deep_dup
    map { |e| e.dup }
  end
end

def pretty(array)
  puts array.map(&:inspect).join("\n")
  puts
end

def zeroes(n)
  n.times.map { n.times.map { n.times.map { Placement.new } } }
end

def n_queens(n)
  candidates = zeroes(n)
  checks = 0
  solutions = 0
  (0...n).each do |i|
    candidates[i][0][i] = Q
    place_next_row(n, candidates[i], 0, checks, solutions)
  end
  p [checks, solutions]
end

def place_next_row(n, candidate, m, checks, solutions)
  candidates = zeroes(n)
  (0...n).each do |i|
    candidates[i] = candidate.deep_dup
    candidates[i][m+1][i] = Q
    result = check_constraints(n, candidates[i])
    puts result ? "Good" : "Bad"
    pretty candidates[i]
    if result
      if n - 1 == m+1
        solutions += 1
      else
        place_next_row(n, candidates[i], m+1, checks, solutions)
      end
    else
      $branches_count += 1
    end
  end
end

def check_constraints(n, candidate)
  return false unless candidate.map { |row| row.index(Q) }.compact.uniq?
  positive_slope = []
  negative_slope = []
  candidate.each_with_index do |row, i|
    next unless col = row.index(Q)
    positive = col + n-1 - i
    positive_slope << positive
    negative = col - n-1 + i
    negative_slope << negative
  end
  return false unless positive_slope.uniq?
  return false unless negative_slope.uniq?
  true
end

n_queens((ARGV.first || 4).to_i)
puts "Branches: #{$branches_count}"
