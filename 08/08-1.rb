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
      (l-line).then {|ll| antinodes << ll if self.key? ll}
      (r+line).then {|rr| antinodes << rr if self.key? rr} 
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
