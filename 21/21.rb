#!/usr/bin/env ruby

require_relative '../utils/grid'
require 'pp'

class Keypad < Grid

  DIR_SYM = {dir[:north] => '^', dir[:east] => '>', dir[:south] => 'v', dir[:west] => '<'}

  attr_reader :locs

  def initialize
    super(pattern)
    @locs = cells.invert
  end

  # Get all the paths from sym1 to sym2 as a string of direction
  def paths_at_step(sym1, sym2)
    return ["A"] if sym1 == sym2
    all_paths(locs[sym1], locs[sym2]) {|v,c| c != 'X'}.map {|path| path.each_cons(2).map {|l,r| DIR_SYM[r-l]}.join + "A"}
  end

  # Get all the possible paths for a given string
  def paths(str)
    f, *r = str.chars.each_cons(2).map {|l,r| paths_at_step(l,r)}
    f.product(*r).map(&:join)
  end

end

class NumericKeypad < Keypad
  def pattern = ["789", "456", "123", "X0A"]
end

class DirKeypad < Keypad
  def pattern = ["X^A", "<v>"]
end

class Robots
  attr_reader :nk, :dk, :codes
  def initialize(io)
    @nk = NumericKeypad.new
    @dk = DirKeypad.new
    @codes = io.readlines.map(&:chomp)
  end

  def shortest_path(input)
    min = Float::INFINITY
    min_input = Float::INFINITY
    keypad_paths = nk.paths("A#{input}").sort_by(&:length)
    # This is a heuristic - skip ones where the input is 4+ chars longer
    # than the min we've found so far
    keypad_paths.delete_if {_1.length > keypad_paths[0].length + 4}
    r2_paths = keypad_paths.flat_map {|r2| dk.paths("A#{r2}") }.sort_by(&:length)
    # Another heuristic
    r2_paths.delete_if {_1.length > r2_paths[0].length + 2}
    r2_paths.each do |r1|
      if (new_min = dk.paths("A#{r1}").min_by(&:length).length) < min
        min = new_min
        min_input = r1.length
      end
    end
    min
  end

  def complexity
    codes.sum { _1.to_i * shortest_path(_1) }
  end
end

r = Robots.new(ARGF)
p r.complexity
