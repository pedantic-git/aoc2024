#!/usr/bin/env ruby

p ARGF.read.scan(%r{(do|don't|mul)\(((\d+),(\d+))?\)}).map {|i,_,x,y| i=="don't"..i=="do" ? 0 : x.to_i*y.to_i }.sum
