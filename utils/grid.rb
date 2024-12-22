require 'forwardable'
require 'matrix'
require 'colorize'

class Grid
  class OutOfBoundsError < StandardError
  end
  class NoPathAvailableError < StandardError
  end
  
  include Enumerable
  extend Forwardable

  def_delegators :@cells, :each, :key?, :select

  attr_reader :cursor, :nw_corner, :se_corner
  attr_accessor :cells

  def initialize(io_or_cells=nil)
    @cursor = nil
    @cells = {}
    if io_or_cells.kind_of? Hash
      @cells = io_or_cells
    else
      io_or_cells.each_with_index {|l,y| l.chomp.chars.each_with_index {|c,x| load_cell(c,y,x)}}
    end
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
    m = directions[m] if m.kind_of? Symbol
    (v + m).then {_1 if @cells.key? _1}
  end

  def move!(m)
    move(m).tap do
      raise OutOfBoundsError if _1.nil?
      self.cursor = _1
    end
  end

  CARDINAL = {
    north: Vector[-1,0],
    east: Vector[0,1],
    south: Vector[1,0],
    west: Vector[0,-1],
  }
  DIAGONAL = {
    northeast: Vector[-1,1],
    southeast: Vector[1,1],
    southwest: Vector[1,-1],
    northwest: Vector[-1,-1],
  }

  def self.directions(diagonal: false)
    diagonal ? CARDINAL.merge(DIAGONAL) : CARDINAL
  end

  def directions(diagonal: false)
    self.class.directions(diagonal: diagonal)
  end
  class <<self
    alias_method :dir, :directions
  end
  alias_method :dir, :directions

  # Just the diagonal directions
  def diagonals
    DIAGONAL
  end

  # Turn a direction matrix right 90 degrees
  def right(v)
    {
      directions[:north] => directions[:east], 
      directions[:east] => directions[:south], 
      directions[:south]=> directions[:west],
      directions[:west] => directions[:north]
    }[v]
  end
  # and left
  def left(v)
    {
      directions[:north] => directions[:west], 
      directions[:west] => directions[:south], 
      directions[:south]=> directions[:east],
      directions[:east] => directions[:north]
    }[v]
  end

  # Get all the neighbours of the given vector (or cursor) that are in bounds.
  # If a block is given, return only the ones for which that block returns true
  # Block arguments are v,c,current,current_c
  def neighbours(v=cursor, diagonal: false)
    directions(diagonal: diagonal).map {|_,m| move(m,v)}.compact.then do |n|
      block_given? ? n.select {|v2| yield v2,self[v2],v,self[v]} : n
    end
  end

  # Get the subset of neighbours that have this char
  def neighbours_with_char(char, v=cursor)
    neighbours(v) {|v,c| c == char}
  end

  def corners
    [Vector[0,0], @cells.keys.map(&:to_a).max]
  end

  def to_s
    nw_corner[0].upto(se_corner[0]).map {|y| nw_corner[1].upto(se_corner[1]).map {|x| render(self[y,x],y,x)}.join}.join("\n")
  end

  # Override this in subclasses to change how a cell is rendered
  def render(c,y,x)
    c.colorize(color(Vector[y,x], c))
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
        tentative = @gscore[current] + edge(current, candidate, @camefrom)
        if tentative < @gscore[candidate]
          @camefrom[candidate] = current
          @gscore[candidate] = tentative
          @fscore[candidate] = tentative + heuristic(current, candidate, start, stop)
          @openset << candidate
        end
      end
    end
    raise NoPathAvailableError, "Failed to find path"
  end

  def heuristic(from, to, start, stop)
    # The default heuristic is just the number of steps east + south to stop
    (stop - from).reduce(:+)
  end

  def edge(current, candidate, previous)
    1
  end

  # Use BFS to get all the possible paths from f to t
  def all_paths(f, t, seen=[f], &block)
    n = neighbours(f) do |v2,c2,v1,c1|
      (!block_given? || block.call(v2,c2,v1,c1)) && !seen.include?(v2)
    end
    if n.find {|v,c| v==t}
      return [seen+[t]]
    else
      n.flat_map {|v,c| all_paths(v, t, seen + [v], &block)}
    end
  end

  protected

  # Load a specific cell - override this if you want to do something else
  # with the data
  def load_cell(c,y,x)
    self[y,x] = c
  end

  # Converts an array containing either y,x or just a vector into a vector
  def cast_vector(arr)
    if arr.length == 1
      arr[0]
    else
      Vector[*arr]
    end
  end
end
