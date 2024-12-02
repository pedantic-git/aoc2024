#!/usr/bin/env ruby

def diffs(report)
  report.each_cons(2).map {_2-_1}
end

def safe?(report)
  diffs(report).then {|d| d.all? {(-3..-1) === _1} || d.all? {(1..3) === _1}} 
end

p ARGF.count { safe? _1.split.map(&:to_i) }
