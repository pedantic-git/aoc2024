#!/usr/bin/env ruby

require_relative '../utils/grid'
require 'pry'

class Maze < Grid

  attr_reader :start, :stop

  def load_cell(c,y,x)
    super
    @start = Vector[y,x] if c == 'S'
    @stop = Vector[y,x] if c == 'E'
  end

  def lowest_score
    path = astar(start, stop) {|v,c| c != '#'}
    paint!(path)
    @gscore[stop]
  end

  def edge(current, candidate, camefrom)
    # Start facing east
    previous = camefrom[current] || current-directions[:east]
    # If we had to turn, it's 1001
    if candidate-current == current-previous
      1
    else
      1001
    end
  end

  # Paint a path onto the grid for illustration
  def paint!(path)
    path.each {self[_1] = '*'}
  end

  COLORS = {
    '#' => :white,
    'S' => :green,
    'E' => :green,
    '*' => :red
  }
  def color(v,c)
    {color: COLORS[c] || :grey}
  end

end

m = Maze.new(ARGF)
puts m
p m.lowest_score
puts m
