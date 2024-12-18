#!/usr/bin/env ruby

require_relative '../utils/grid'

class Pushdown < Grid

  attr_reader :width, :queue

  def initialize(width, io)
    @cells = {}
    @width = width
    @queue = io.map {|s| Vector[*s.split(',').reverse.map(&:to_i)]}
    reset!
    set_corners!
  end

  def reset!
    width.times {|y| width.times {|x| self[y,x] = '.'}}
  end

  # Drop the first n bytes onto the grid
  def drop(n)
    queue.first(n).each {self[_1] = '#'}
  end

  # Find the first bad number of bytes
  def find_first_bad
    n = 1024
    loop do
      n += 1
      puts n
      reset!
      drop(n)
      astar(nw_corner, se_corner) {self[_1] != '#'}
    end
  rescue NoPathAvailableError
    return queue[n-1]
  end
end

p = Pushdown.new(71, ARGF)
puts p.find_first_bad.to_a.reverse.join(",")

