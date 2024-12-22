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

  def move_box(v, m)
    # First - get the rest of the box
    box = if self[v] == '['
      [v, v+dir[:east]]
    else
      [v+dir[:west], v]
    end
    case m
    when dir[:west]
      case self[box[0]+m]
      when '.'
        self[box[0]+m] = '['
        self[box[0]] = ']'
        self[box[1]] = '.'
        true
      when ']'
        move_box(box[0]+m, m) && move_box(box[0], m)
      else
        false
      end
    when dir[:east]
      case self[box[1]+m]
      when '.'
        self[box[1]+m] = ']'
        self[box[1]] = '['
        self[box[0]] = '.'
        true
      when '['
        move_box(box[1]+m, m) && move_box(box[0], m)
      else
        false
      end
    when dir[:north], dir[:south]
      case [self[box[0]+m], self[box[1]+m]]
      when ['.', '.']
        self[box[0]] = self[box[1]] = '.'
        self[box[0]+m] = '['
        self[box[1]+m] = ']'
        true
      when ['[', ']']
        move_box(box[0]+m, m) && move_box(box[0], m)
      when [']', '[']
        # if moving box 0 succeeds but moving box 1 fails then we have to
        # undo the first
        if move_box(box[0]+m, m)
          if move_box(box[1]+m, m)
            move_box(box[0], m)
          else
            move_box(box[0]+m+m, -m)
            false
          end
        else
          false
        end
      else
        false
      end
    end
  end

  # def move_box(v, dir)
  #   case dir
  #   when directions[:west], directions[:east]
  #     case self[v+2*dir]
  #     when '.'
  #       # Space to move the box into
  #       self[v+2*dir] = self[v+dir]
  #       self[v+dir] = self[v]
  #       self[v] = '.'
  #       return true
  #     when '[', ']'
  #       if move_box(v+2*dir, dir)
  #         self[v+2*dir] = self[v+dir]
  #         self[v+dir] = self[v]
  #         self[v] = '.'
  #         return true
  #       else
  #         return false
  #       end
  #     else
  #       false
  #     end
  #   else
  #     # First, we need to find the other half of the box
  #     whole_box = self[v] == '[' ? [v, v+directions[:east]] : [v+directions[:west], v]
  #     p whole_box
  #     box_space = [whole_box[0]+dir, whole_box[1]+dir]
  #     p box_space
  #     case [self[box_space[0]], self[box_space[1]]]
  #     when ['.','.']
  #       # Space to move the box into
  #       self[box_space[0]] = '['
  #       self[box_space[1]] = ']'
  #       self[whole_box[0]] = self[whole_box[1]] = '.'
  #       return true
  #     when ['[', ']']
  #       # Box aligned with this one
  #       if move_box(box_space[0]+dir, dir)
  #         self[box_space[0]] = '['
  #         self[box_space[1]] = ']'
  #         self[whole_box[0]] = self[whole_box[1]] = '.'
  #         return true
  #       else
  #         return false
  #       end
  #     when [']', '[']
  #       # Two boxes
  #       if move_box(box_space[0]+dir, dir) && move_box(box_space[1]+dir, dir)
  #         self[box_space[0]] = '['
  #         self[box_space[1]] = ']'
  #         self[whole_box[0]] = self[whole_box[1]] = '.'
  #         return true
  #       else
  #         return false
  #       end
  #     else
  #       return false
  #     end
  #   end
  # end

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
