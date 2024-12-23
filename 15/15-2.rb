#!/usr/bin/env ruby

require_relative '../utils/grid'
require 'pry'

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
    '^' => dir[:north],
    '>' => dir[:east],
    'v' => dir[:south],
    '<' => dir[:west]
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

  # Given half a box, get the whole box
  def get_box(v)
    if self[v] == '['
      [v, v+dir[:east]]
    else
      [v+dir[:west], v]
    end
  end

  # Can this box be moved? Don't move it unless this is true
  def can_move_box?(v, m)
    # First - get the rest of the box
    box = get_box(v)
    case m
    when dir[:west]
      case self[box[0]+m]
      when '.'
        true
      when ']'
        can_move_box?(box[0]+m, m)
      else
        false
      end
    when dir[:east]
      case self[box[1]+m]
      when '.'
        true
      when '['
        can_move_box?(box[1]+m, m)
      else
        false
      end
    else
      case [self[box[0]+m], self[box[1]+m]]
      when ['.', '.']
        true
      when ['[', ']']
        can_move_box?(box[0]+m, m)
      when [']', '[']
        can_move_box?(box[0]+m, m) && can_move_box?(box[1]+m, m)
      else
        false
      end
    end
  end

  def move_box(v, m)
    # We need to test if we can move before we move anything
    return unless can_move_box?(v, m)
    box = get_box(v)
    case m
    when dir[:west]
      move_box(box[0]+m, m) if self[box[0]+m] == ']'
      self[box[0]+m] = '['
      self[box[0]] = ']'
      self[box[1]] = '.'
    when dir[:east]
      move_box(box[1]+m, m) if self[box[1]+m] == '['
      self[box[1]+m] = ']'
      self[box[1]] = '['
      self[box[0]] = '.'
    else
      move_box(box[0]+m, m) if self[box[0]+m] == '['
      if self[box[0]+m] == ']'
        move_box(box[0]+m, m)
        move_box(box[1]+m, m)
      end
      self[box[0]] = self[box[1]] = '.'
      self[box[0]+m] = '['
      self[box[1]+m] = ']'
    end
  end

  # Call move_robot! on every instruction
  def move_all!
    instructions.each { puts _1; move_robot! _1; puts self}
  end

  # Get the GPS of all the boxes
  def gps
    cells.sum {|v,c| c == '[' ? v[0]*100+v[1] : 0}
  end

end

w = Warehouse.new(ARGF)
w.move_all!
#puts w
p w.gps
