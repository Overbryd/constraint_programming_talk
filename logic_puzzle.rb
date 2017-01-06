require_relative "lib/amb.rb"

# How to solve a grid based logic puzzle?
#
# 1. Read the clues and gather all facts
# 2. Lay down constraints
# 3. Run the solver :)
#
# Taken from http://www.logic-puzzles.org
#
# 1. The title that sold 19 copies wasn't written by Jeff Holman.
# 2. Matt Stevens's book sold 14 more copies than My Best Friend.
# 3. Roscoe Jones's book sold 14 fewer copies than Alexis Olson's book.
# 4. Of Zara's Game and the title that sold 40 copies, one was written by Alexis Olson and the other was written by Matt Stevens.
# 5. Away in Arles sold 12 copies.
# 6. Roscoe Jones's book sold somewhat more copies than Bill Orega's book.
# 7. Two for Tennis is either the book that sold 26 copies or Bill Orega's book.

FACTS = {
  title: [
    "Away in Arles",
    "Call of Duty",
    "My Best Friend",
    "Two for Tennis",
    "Zara's Game"
  ],
  copies_sold: [
    12,
    19,
    26,
    33,
    40
  ],
  author: [
    "Alexis Olson",
    "Bill Orega",
    "Jeff Holman",
    "Matt Stevens",
    "Roscoe Jones"
  ]
}

class Book < Struct.new(:title, :copies_sold, :author)
  def self.shelf
    @shelf ||= []
  end

  def self.by_title(title)
    shelf.find { |book| book.title == title }
  end

  def self.by_copies_sold(copies_sold)
    shelf.find { |book| book.copies_sold == copies_sold }
  end

  def self.by_author(author)
    shelf.find { |book| book.author == author }
  end
end

# initialize our Book.shelf
FACTS[:copies_sold].each do |copies_sold|
  book = Book.new(nil, copies_sold, nil)
  Book.shelf << book
end

Book.shelf.each do |book|
  book.title = Amb.choose(FACTS[:title])
  book.author = Amb.choose(FACTS[:author])
end

# 1. The title that sold 19 copies wasn't written by Jeff Holman.
copies_sold_19 = Book.by_copies_sold(19)
if copies_sold_19
  Amb.assert copies_sold_19.author != "Jeff Holman"
end

# 2. Matt Stevens's book sold 14 more copies than My Best Friend.
matt_stevens_book = Book.by_author("Matt Stevens")
my_best_friend = Book.by_title("My Best Friend")
if matt_stevens_book && my_best_friend
  Amb.assert matt_stevens_book.copies_sold == my_best_friend.copies_sold + 14
end

# 3. Roscoe Jones's book sold 14 fewer copies than Alexis Olson's book.
roscoe_jones_book = Book.by_author("Roscoe Jones")
alexis_olsons_book = Book.by_author("Alexis Olson")
if roscoe_jones_book && alexis_olsons_book
  Amb.assert roscoe_jones_book.copies_sold == alexis_olsons_book.copies_sold - 14
end

# 4. Of Zara's Game and the title that sold 40 copies,
# one was written by Alexis Olson and the other was written by Matt Stevens.
zaras_game = Book.by_title("Zara's Game")
copies_sold_40 = Book.by_copies_sold(40)
if zaras_game && copies_sold_40
  author_diff = ["Alexis Olson", "Matt Stevens"] - [zaras_game.author, copies_sold_40.author]
  Amb.assert author_diff.empty?
end

# 5. Away in Arles sold 12 copies.
if away_in_arles = Book.by_title("Away in Arles")
  Amb.assert away_in_arles.copies_sold == 12
end

# 6. Roscoe Jones's book sold somewhat more copies than Bill Orega's book.
if roscoe_jones_book && (bill_oregas_book = Book.by_author("Bill Orega"))
  Amb.assert roscoe_jones_book.copies_sold > bill_oregas_book.copies_sold
end

# 7. Two for Tennis is either the book that sold 26 copies or Bill Orega's book.
if two_for_tennis = Book.by_title("Two for Tennis")
  Amb.assert (two_for_tennis.copies_sold == 26) ^ (two_for_tennis.author == "Bill Orega")
end

Amb.assert Book.shelf.map(&:title).uniq.size == 5
Amb.assert Book.shelf.map(&:author).uniq.size == 5

require 'pp'
pp Book.shelf

