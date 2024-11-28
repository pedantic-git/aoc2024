require 'forwardable'
require 'matrix'
require 'colorize'

class Grid
  class OutOfBoundsError < StandardError
  end
  
  include Enumerable
  extend Forwardable

  def_delegators :@cells, :each

  attr_reader :cursor, :nw_corner, :se_corner
  attr_accessor :cells

  def initialize(io_or_cells=nil)
    @cells = {}
    if io_or_cells.kind_of? Hash
      @cells = io_or_cells
    else
      io_or_cells.each_with_index {|l,y| l.chomp.chars.each_with_index {|c,x| self[y,x] = c}}
    end
    @cursor = nil
    set_corners!
  end

  def dup
    self.class.new(cells.dup).tap do |g|
      g.cursor = cursor
    end
  end

  def []=(*v, c)
    v = cast_vector(v)
    @cells[v] = c
  end

  def [](*v)
    v = cast_vector(v)
    @cells[v]
  end

  def cursor=(v)
    v = Vector[*v] if v.kind_of? Array
    @cursor = v
  end

  # Move by the given Vector and return the new coordinates or nil if out of bounds
  # Doesn't update the cursor - use move! if you want to do that
  def move(m, v=cursor)
    (v + m).then {_1 if @cells.key? _1}
  end

  def move!(m)
    move(m).tap do
      raise OutOfBoundsError if _1.nil?
      self.cursor = _1
    end
  end

  def north(v=cursor)
    move(Vector[-1,0], v)
  end

  def east(v=cursor)
    move(Vector[0,1], v)
  end

  def south(v=cursor)
    move(Vector[1,0], v)
  end
  
  def west(v=cursor)
    move(Vector[0,-1], v)
  end

  # Get all the neighbours of the given vector (or cursor) that are in bounds.
  # If a block is given, return only the ones for which that block returns true
  def neighbours(v=cursor)
    [north(v), east(v), south(v), west(v)].compact.then do |n|
      block_given? ? n.select {|v| yield v,self[v]} : n
    end
  end

  def corners
    [Vector[0,0], @cells.keys.map(&:to_a).max]
  end

  def to_s
    nw_corner[0].upto(se_corner[0]).map {|y| nw_corner[1].upto(se_corner[1]).map {|x| self[y,x].colorize(color(Vector[y,x], self[y,x]))}.join}.join("\n")
  end

  # Override this in subclasses to colorize a cell
  def color(v, c)
    {color: :grey}
  end

  # Set the nw_corner and se_corner based on the grid as we currently understand it
  def set_corners!
    @nw_corner = Vector[@cells.keys.map {_1[0]}.min, @cells.keys.map {_1[1]}.min]
    @se_corner = Vector[@cells.keys.map {_1[0]}.max, @cells.keys.map {_1[1]}.max]
  end

  # Run an A* algorithm to find the shortest path from start to stop, applying
  # the heuristic function called #heuristic. The weight of an edge is determined by
  # #edge. If a block is supplied it is used to filter neighbours.
  def astar(start, stop, &block)
    @openset = Set.new([start])
    @camefrom = {}
    @gscore = Hash.new(Float::INFINITY)
    @gscore[start] = 0
    @fscore = Hash.new(Float::INFINITY)
    @fscore[start] = heuristic(start, start, start, stop)
    while @openset.any?
      current = @openset.min_by {@fscore[_1]}
      if current == stop
        return [stop].tap do |p|
          while @camefrom.key? p[0]
            p.unshift(@camefrom[p[0]])
          end
        end
      end
      @openset.delete(current)
      neighbours(current, &block).each do |candidate|
        tentative = @gscore[current] + edge(current, candidate)
        if tentative < @gscore[candidate]
          @camefrom[candidate] = current
          @gscore[candidate] = tentative
          @fscore[candidate] = tentative + heuristic(current, candidate, start, stop)
          @openset << candidate
        end
      end
    end
    raise "Failed to find path"
  end

  def heuristic(from, to, start, stop)
    # The default heuristic is just the number of steps east + south to stop
    (stop - v).reduce(:+)
  end

  def edge(v1, v2)
    1
  end

  protected

  # Set the width and height based on what's in there

  # Converts an array containing either y,x or just a vector into a vector
  def cast_vector(arr)
    if arr.length == 1
      arr[0]
    else
      Vector[*arr]
    end
  end
end
