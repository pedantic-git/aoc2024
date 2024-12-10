#!/usr/bin/env ruby

require_relative '../utils/grid'

class Island < Grid

  # Find all the locations of the trailheads on the map
  def trailheads
    select {|v,c| c == '0'}.keys
  end

  # Given a trailhead (or any cell) count how many 9s are reachable from it
  def score(v, seen: [], track_seen: true)
    seen << v if track_seen # track where we've been 
    # Base case 1: We've found a 9
    return 1 if self[v] == '9'
    # Calculate where we can go next
    valid_moves = neighbours_with_char("#{self[v].to_i + 1}", v) - seen
    # Base case 2: Dead end
    return 0 if valid_moves.empty?
    # Recursive case - follow all the valid moves
    valid_moves.sum { score(_1, seen: seen, track_seen: track_seen) }
  end

  # The rating for a cell is the same as score but without tracking where
  # we've been
  def rating(v)
    score(v, track_seen: false)
  end

  # Get the score for all the trailheads and add them together
  def total_score
    trailheads.sum {score _1}
  end

  # Get the rating for all the trailheads and add them together
  def total_rating
    trailheads.sum {rating _1}
  end

end

i = Island.new(ARGF)
p i.total_score
p i.total_rating