#!/usr/bin/env ruby

require_relative '../utils/grid'

class Island < Grid

  def load_cell(c,y,x)
    self[y,x] = c  == '.' ? nil : c.to_i
  end

  def render(c,y,x)
    c ? c.to_s : '.'
  end

  # Find all the locations of the trailheads on the map
  def trailheads
    select {|v,c| c == 0}.keys
  end

  # Given a trailhead (or any cell) count how many 9s are reachable from it
  def score(v=cursor, seen=[])
    seen << v # don't follow the same trail multiple times if we arrive at it again
    return 1 if self[v] == 9 # base case - we've found one
    valid_moves = neighbours_with_char(self[v] + 1, v) - seen
    return 0 if valid_moves.empty? # dead end
    return valid_moves.sum {score(_1, seen)}
  end

  # Get the score for all the trailheads and add them together
  def total_score
    trailheads.sum {score(_1)}
  end

end

i = Island.new(ARGF)
p i.total_score
