#!/usr/bin/env ruby

require_relative '../utils/grid'
require 'set'

class Collinearity < Grid

  attr_reader :frequencies, :antinodes

  def initialize(io_or_cells=nil)
    @frequencies = {}
    @antinodes = Set.new
    super
    frequencies.each_key {|f| add_antinodes! f}
  end

  def load_cell(c,y,x)
    super
    return if c == '.'
    frequencies[c] ||= []
    frequencies[c] << Vector[y,x]
  end

  # Add the antinodes for a given frequency
  def add_antinodes!(freq)
    frequencies[freq].combination(2) do |l,r|
      line = r-l

      # Actually a use for a for(init;cond;next) loop...!
      next_l = r-line # note: r-line not l-line because l is the first antinode
      while self.key? next_l
        antinodes << next_l
        next_l -= line
      end

      next_r = l+line
      while self.key? next_r
        antinodes << next_r
        next_r += line
      end
    end
  end

  def color(v, c)
    if antinodes === v
      {color: :yellow}
    elsif c == '.'
      {color: :grey}
    else
      {color: :red}
    end
  end

end

c = Collinearity.new(ARGF)
puts c
p c.antinodes.length
