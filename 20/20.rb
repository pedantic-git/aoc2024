#!/usr/bin/env ruby

require_relative '../utils/grid'

Cheat = Struct.new(:v1, :v2)

class Race < Grid

  attr_reader :start, :stop, :clean

  def initialize(io)
    super
    @clean = cells.dup
  end

  def reset!
    @cells = clean.dup
  end

  
  def fastest
    astar(start, stop) {|v,c,current,current_c| c != '#' && !(c == '1' && current_c == '2')}.tap do |path|
      path.each {self[_1] = 'X'}
    end
  end

  # The possible cheats are every pair of neighbours where 1 is a # and 2 is a .
  def possible_cheats
    flat_map {|v1,c1| c1 == '#' ? neighbours(v1) {|_,c2| %w[. E].include? c2}.map {|v2| Cheat.new(v1,v2)} : []}
  end

  def cheat!(cheat)
    self[cheat.v1] = '1'; self[cheat.v2] = '2'
  end

  # Produces a hash of cheat to its maximum saving
  def savings
    reset!
    possible = possible_cheats
    puts possible.length
    slowest = fastest.length
    possible.to_h do |cheat|
      p cheat
      reset!
      cheat! cheat
      [cheat, slowest - fastest.length]
    end
  end

  def load_cell(c,y,x)
    super
    @start = Vector[y,x] if c == 'S'
    @stop = Vector[y,x] if c == 'E'
  end

  def color(v,c)
    case c
    when '#'
      {color: :white}
    when 'S', 'E'
      {color: :green, mode: :bold}
    when '1', '2'
      {color: :blue, mode: :bold}
    when 'X'
      {color: :red}
    else
      {color: :grey}
    end
  end

end

r = Race.new(ARGF)
p r.savings.count {|c,n| n >= 100}

