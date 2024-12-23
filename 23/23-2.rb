#!/usr/bin/env ruby

require 'set'

from = {}
ARGF.each {/(..)-(..)/.match(_1).captures.then {|l,r| from[l] ||= Set.new; from[l] << r; from[r] ||= Set.new; from[r] << l}}

candidates = from.keys.map {Set.new([_1])}

from.keys.each do |x|
  candidates.each do |set|
    next if set.include? x
    if set.all? {from[x].include? _1}
      set << x
    else
      set -= from[x]
    end
  end
end

puts candidates.max_by(&:length).sort.join(",")


