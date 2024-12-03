#!/usr/bin/env ruby

# Hideous global variables
on = true
sum = 0

ARGF.read.scan %r{(do|don't|mul)\(((\d+),(\d+))?\)} do |inst, _, x,y|
  case inst
  when 'do'
    on = true
  when "don't"
    on = false
  when 'mul'
    sum += x.to_i*y.to_i if on
  end
end

p sum