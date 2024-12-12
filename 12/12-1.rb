#!/usr/bin/env ruby

require_relative '../utils/grid'

class Farm < Grid

  attr_reader :regions

  def initialize(io)
    super
    @regions = {}
    detect_regions!
  end

  def detect_regions!
    current_region = 1
    each do |v,c|
      existing = neighbours_with_char(c, v).select { regions.key? _1 }
      existing_regions = regions.values_at(*existing).sort.uniq
      if existing.length == 0
        # We've found a new region
        regions[v] = current_region
        current_region += 1
      elsif existing_regions.length == 1
        # We're just adding to a region
        regions[v] = regions[existing.first]
      else
        # Merge two or more regions
        keep, *go = existing_regions
        regions[v] = keep
        regions.each {|v,c| regions[v] = keep if go.include? regions[v]}
      end
    end      
  end

  REGION_COLORS = {0 => :red, 1 => :cyan, 2 => :magenta, 3 => :green, 4 => :blue, 5 => :yellow, 6 => :light_red, 7 => :light_cyan, 8 => :light_green, 9 => :light_blue}
  
  def color(v,c)
    {color: REGION_COLORS[regions[v] % 10]}
  end

end

f = Farm.new(ARGF)
p f.regions
puts f
