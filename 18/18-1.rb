#!/usr/bin/env ruby

require_relative '../utils/grid'

class Pushdown < Grid

  attr_reader :queue

  def initialize(width, io)
    @cells = {}
    width.times {|y| width.times {|x| self[y,x] = '.'}}
    @queue = io.map {|s| Vector[*s.split(',').reverse.map(&:to_i)]}
    set_corners!
  end

  # Drop the first n bytes onto the grid
  def drop(n)
    queue.first(n).each {self[_1] = '#'}
  end

  # Find the exit in the shortest time and return the path
  def find_exit
    astar(nw_corner, se_corner) {self[_1] != '#'}.tap do |path|
      path.each {self[_1] = 'O'}
    end
  end

  COLORS = {'#' => :red, 'O' => :green}
  def color(v,c)
    {color: COLORS[c] || :grey}
  end

end

p = Pushdown.new(71, ARGF)
p.drop(1024)
puts p.find_exit.length-1
puts p
