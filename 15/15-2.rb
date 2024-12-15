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
    x = x*2
    if c == 'O'
      self[y,x] = '['
      self[y,x+1] = ']'
    elsif c == '@'
      self[y,x] = c
      self[y,x+1] = '.'
      self.cursor = Vector[y,x]
    else
      self[y,x] = self[y,x+1] = c
    end
  end

  def color(v,c)
    case c
    when '@'
      {color: :red, mode: :bold}
    when '[', ']'
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
    when '[', ']'
      # If the box moves, move the robot. Otherwise don't do anything.
      if move_box(next_robot, dir)
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

  def move_box(v, dir)
    case dir
    when directions[:west], directions[:east]
      case self[v+2*dir]
      when '.'
        # Space to move the box into
        self[v+2*dir] = self[v+dir]
        self[v+dir] = self[v]
        self[v] = '.'
        return true
      when '[', ']'
        if move_box(v+2*dir, dir)
          self[v+2*dir] = self[v+dir]
          self[v+dir] = self[v]
          self[v] = '.'
          return true
        else
          return false
        end
      else
        false
      end
    else
      # TODO
      false
    end
  end

  # Call move_robot! on every instruction
  def move_all!
    instructions.each { move_robot! _1}
  end

  # Get the GPS of all the boxes
  def gps
    cells.sum {|v,c| c == '[' ? v[0]*100+v[1] : 0}
  end

end

w = Warehouse.new(ARGF)
#w.move_all!
w.move_robot!('^')
w.move_robot!('<')
w.move_robot!('<')
puts w
p w.gps
