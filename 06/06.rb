#!/usr/bin/env ruby

require_relative '../utils/grid'

class Lab < Grid
  attr_accessor :dir

  def initialize(io)
    super
    find_guard!
    self.dir = :north
  end

  def color(v, c)
    case c
    when '#' then {color: :yellow}
    when 'X' then {color: :red}
    when '^' then {color: :white, mode: :bold}
    else {color: :grey}
    end
  end

  def next_dir
    {north: :east, east: :south, south: :west, west: :north}[dir]
  end

  def move_guard!
    if ['.', 'X', nil].include? self[move(dir)]
      self[cursor] = 'X'
      move!(dir)
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

  private

  def find_guard!
    find {|v,c| c == '^'}.then {|v,_| self.cursor = v}
  end

end

l = Lab.new(ARGF)
l.run!
puts l
p l.count_visited
