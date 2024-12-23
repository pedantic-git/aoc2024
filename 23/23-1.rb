#!/usr/bin/env ruby

require 'set'
require 'pp'

from = {}
ARGF.each {/(..)-(..)/.match(_1).captures.then {|l,r| from[l] ||= Set.new; from[l] << r; from[r] ||= Set.new; from[r] << l}}

sets = Set.new
from.each do |f,t|
  t.each do |x|
    from[x].each do |y|
      sets << Set.new([f,x,y]) if from[y].include?(f)
    end
  end
end

ts = Set.new(from.keys.grep /t/)
p sets.count {_1.intersect? ts}
