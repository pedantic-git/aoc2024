#!/usr/bin/env ruby

require_relative '../utils/grid'

class Warehouse < Grid

  attr_reader :instructions

  def initialize(io)
    # Break the input data into grid and instructions
    grid, _, inst = io.chunk {|l| l == "\n"}.map {_1[1]}
    super grid
    @instructions = inst.flat_map {_1.chomp.chars}
  end

  def load_cell(c,y,x)
    super
    self.cursor = Vector[y,x] if c == '@'
  end

  def color(v,c)
    case c
    when '@'
      {color: :red, mode: :bold}
    when 'O'
      {color: :light_yellow}
    when '#'
      {color: :blue}
    else
      {color: :grey}
    end
  end

  DIRS = {
    '^' => directions[:north],
    '>' => directions[:east],
    'v' => directions[:south],
    '<' => directions[:west]
  }

  # Move the robot (and any boxes) in the specified direction, if possible
  def move_robot!(dir)
    dir = DIRS[dir]
    next_robot = move dir
    case self[next_robot]
    when '#'
      return
    when 'O'
      # It's a box - find the last box in this row
      box = next_robot
      until self[(next_box = move(dir, box))] != 'O'
        box = next_box
      end
      if self[next_box] == '.'
        self[next_box] = 'O'
        self[cursor] = '.'
        move!(dir)
        self[cursor] = '@'
      end
    else
      self[cursor] = '.'
      move!(dir)
      self[cursor] = '@'
    end
  end

  # Call move_robot! on every instruction
  def move_all!
    instructions.each { move_robot! _1}
  end

  # Get the GPS of all the boxes
  def gps
    cells.sum {|v,c| c == 'O' ? v[0]*100+v[1] : 0}
  end

end

w = Warehouse.new(ARGF)
w.move_all!
puts w
p w.gps
