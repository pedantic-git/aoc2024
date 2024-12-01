#!/usr/bin/env ruby

p ARGF.map {_1.split.map(&:to_i)}.transpose.then {|a,b| a.sort.zip(b.sort)}.map {|l,r| (r-l).abs}.sum