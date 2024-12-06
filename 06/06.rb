#!/usr/bin/env ruby

require 'set'
require_relative '../utils/grid'

class Lab < Grid
  class LoopError < StandardError; end

  attr_accessor :dir, :have_been

  def initialize(io)
    super
    find_guard!
    self.have_been = Set.new
    @reset = cells.dup
  end

  def color(v, c)
    case c
    when '#' then {color: :yellow}
    when 'X' then {color: :red}
    when 'O' then {color: :green, mode: :bold}
    when '^' then {color: :white, mode: :bold}
    else {color: :grey}
    end
  end

  def next_dir
    {north: :east, east: :south, south: :west, west: :north}[dir]
  end

  def move_guard!
    next_v = move(dir)
    if ['.', 'X', nil].include? self[next_v]
      self[cursor] = 'X'
      move!(dir)
      # If the guard has been to this exact same spot facing the same direction,
      # we're in a loop
      raise LoopError if have_been.include? [cursor, dir]
      have_been << [cursor, dir]
    else
      self.dir = next_dir
    end
  end

  def run!
    loop { move_guard! }
  rescue OutOfBoundsError
  end

  def count_visited
    count {|_,c| c == 'X'}
  end

  def reset!
    self.cells = @reset.dup
    self.have_been = Set.new
    find_guard!
  end

  # Try placing an obstacle at every location and count the ones that result
  # in a LoopError
  def n_loop_obstacles
    loops = 0
    each do |v,c|
      reset!
      next if self[v] != '.'
      self[v] = 'O'
      begin
        run!
      rescue LoopError
        puts self
        loops += 1
      end
    end
    loops
  end

  private

  def find_guard!
    find {|v,c| c == '^'}.then {|v,_| self.cursor = v; self.dir = :north }
  end

end

# Part 1
l = Lab.new(ARGF)
l.run!
puts l
p l.count_visited

# Part 2 - this takes a long time to run and prints a lot of output
p l.n_loop_obstacles
