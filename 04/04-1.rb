#!/usr/bin/env ruby

require_relative '../utils/grid'

class Ceres < Grid

  # Returns n times XMAS appears radiating from this square
  def nxmas(v=cursor)
    return 0 if self[v] != 'X'
    directions(diagonal: true).count do |dir, m|
      self[v+m] == 'M' &&
      self[v+m+m] == 'A' &&
      self[v+m+m+m] == 'S'
    end
  end
  
end

ceres = Ceres.new(ARGF)
p ceres.map {|v,c| ceres.nxmas(v)}.sum
