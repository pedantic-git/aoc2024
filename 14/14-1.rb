#!/usr/bin/env ruby

require 'matrix'

WIDTH = 101
HEIGHT = 103

class Robot
  attr_accessor :pos, :vel

  def initialize(str)
    /p=(.+),(.+) v=(.+),(.+)/ =~ str
    @pos = Vector[$1.to_i, $2.to_i]
    @vel = Vector[$3.to_i, $4.to_i]
  end

  def move(steps)
    new_pos = pos + vel*steps
    self.pos = Vector[new_pos[0] % WIDTH, new_pos[1] % HEIGHT]
  end
end

class Field
  attr_reader :robots

  def initialize(io)
    @robots = io.map { Robot.new _1 }
  end

  def move(steps)
    robots.each { _1.move steps }
  end

  def quadrants
    midwidth = WIDTH/2
    midheight = HEIGHT/2
    [
      [0..midwidth-1, 0..midheight-1], # NW
      [midwidth+1..WIDTH-1, 0..midheight-1], # NE
      [0..midwidth-1, midheight+1..HEIGHT-1], # SW
      [midwidth+1..WIDTH-1, midheight+1..HEIGHT-1], # SE
    ]
  end

  # Very inefficient but it's a small amount of data so who cares
  # Give two ranges and count all the robots in that range
  def robots_in_quadrant(r1, r2)
    robots.count {|r| r1.include?(r.pos[0]) && r2.include?(r.pos[1])}
  end

  def safety_factor
    quadrants.map {robots_in_quadrant *_1}.reduce(:*)
  end
end

f = Field.new(ARGF)
f.move(100)
p f.safety_factor

