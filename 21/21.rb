#!/usr/bin/env ruby

require_relative '../utils/grid'

class Keypad < Grid
  attr_reader :locs, :robot

  def initialize(n_robots)
    super(shape)
    @locs = cells.invert
    @robot = n_robots.zero? ? nil : DirKeypad.new(n_robots - 1)
  end

  def shape = []

  def between(x,y)
    astar(locs[x], locs[y]) {|v,c| c != 'X'}.each_cons(2).sum {|f,t| edge f,t}
  end
end

class NumericKeypad < Keypad
  def shape = ["789", "456", "123", "X0A"]

  def dir_symbol(dir)
    {directions[:north] => '^', directions[:east] => '>', 
     directions[:south] => 'v', directions[:west] => '<'}[dir]
  end

  def edge(current, candidate, previous=nil)
    symbol_to_press = dir_symbol(candidate-current)
    robot ? robot.between('A', symbol_to_press) + robot.between(symbol_to_press, 'A') : 1
  end
end

class DirKeypad < Keypad
  def shape = ["X^A", "<v>"]

  def edge(current, candidate, previous=nil)
    1 + (robot ? robot.between(self[current], self[candidate]) : 0)
  end
end

nk = NumericKeypad.new(2)
puts nk.between('A', '0')

# NumericKeypad = <A = 2
# Robot1        = v<<A >>^A = 6
# Robot2        = v<A v<<A A >>^A A <A >A = 17
