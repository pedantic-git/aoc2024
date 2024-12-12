#!/usr/bin/env ruby

require_relative '../utils/grid'

class RegionSet < Set

  def price
    length * sum {|x| Grid.directions.count {|_,m| !include? x+m} }
  end

end

class Farm < Grid

  attr_reader :regions
  attr_accessor :n_regions

  def initialize(io)
    super
    @regions = {}
    @n_regions = 0
    detect_regions!
  end

  def detect_regions!
    each do |v,c|
      existing = neighbours_with_char(c, v).select { regions.key? _1 }
      existing_regions = regions.values_at(*existing).sort.uniq
      if existing.length == 0
        # We've found a new region
        self.n_regions += 1
        regions[v] = n_regions
      elsif existing_regions.length == 1
        # We're just adding to a region
        regions[v] = regions[existing.first]
      else
        # Merge two or more regions
        keep, *go = existing_regions
        regions[v] = keep
        # This could be faster but it's fast enough
        regions.each {|v,c| regions[v] = keep if go.include? regions[v]}
      end
    end      
  end

  # Get all the regions as RegionSet objects in a hash with the key being the
  # region number
  def region_sets
    @region_sets ||= regions.inject({}) {|h,(v,i)| h[i] ||= RegionSet.new; h[i] << v; h}
  end

  def total_price
    region_sets.values.sum(&:price)
  end

  REGION_COLORS = {0 => :red, 1 => :cyan, 2 => :magenta, 3 => :green, 4 => :blue, 5 => :yellow, 6 => :light_red, 7 => :light_cyan, 8 => :light_green, 9 => :light_blue}
  
  def color(v,c)
    {color: REGION_COLORS[regions[v] % 10]}
  end

end

f = Farm.new(ARGF)
puts f
p f.total_price
