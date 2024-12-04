#!/usr/bin/env ruby

require_relative '../utils/grid'

class Ceres < Grid

  # Returns the cells at the diagonals in order as a string
  def diagstr(v=cursor)
    diagonals.map {|_,m| self[v+m]}.join
  end

  # True if v is the centre of an X-MAS
  def x_mas?(v=cursor)
    return false unless self[v] == 'A'
    %w[MMSS SMMS SSMM MSSM].include? diagstr(v)
  end
  
end

ceres = Ceres.new(ARGF)
p ceres.count {|v, c| ceres.x_mas? v}
