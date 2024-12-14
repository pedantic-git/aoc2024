#!/usr/bin/env ruby

require_relative '../utils/grid'

WIDTH = 101
HEIGHT = 103
MID_COLUMN = WIDTH / 2

class Robot
  attr_accessor :pos, :vel

  def initialize(str)
    /p=(.+),(.+) v=(.+),(.+)/ =~ str
    @pos = Vector[$2.to_i, $1.to_i]
    @vel = Vector[$4.to_i, $3.to_i]
  end

  def move(steps)
    new_pos = pos + vel*steps
    self.pos = Vector[new_pos[0] % HEIGHT, new_pos[1] % WIDTH]
  end
end

class Bathroom < Grid
  attr_reader :robots
  attr_accessor :moves

  def initialize(io)
    @cells = {}
    0.upto(HEIGHT-1).each {|y| 0.upto(WIDTH-1).each {|x| self[y,x] = 0}}
    set_corners!

    @robots = io.map { Robot.new(_1).tap {|r| self[r.pos] += 1 }}
    @moves = 0
  end

  def move(steps=1)
    robots.each do |robot|
      old_pos = robot.pos
      robot.move steps
      self[old_pos] -= 1
      self[robot.pos] += 1
    end
    self.moves += steps
  end

  def set_corners!
    @nw_corner = Vector[0, 0]
    @se_corner = Vector[HEIGHT-1, WIDTH-1]
  end

  def render(c,y,x)
    if c > 0
      '*'.colorize(:green)
    else
      '.'.colorize(:grey)
    end
  end

  # The bathroom is suspicious if more 30 squares in row 86 contain a robot
  def suspicious?
    (0..WIDTH-1).count {|x| self[86, x] > 0} > 30
  end
end

b = Bathroom.new(ARGF)
loop do
  b.move
  if b.moves % 10000 == 0
    puts b.moves
  end 
  if b.suspicious?
    puts b.moves
    puts b
  end
end
