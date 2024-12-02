#!/usr/bin/env ruby

class Array
  # duplicate of this array without a specific index
  def without_at(i)
    dup.then { _1.delete_at(i); _1 }
  end
end

# Given a report, provide all the options for this report with the dampener
# applied
def options(report)
  [report] + report.each_index.map { report.without_at(_1) }
end

# Get a list of step sizes in a specific report option
def diffs(option)
  option.each_cons(2).map {_2-_1}
end

# Checks if a specific report option is safe
def option_safe?(option)
  diffs(option).then {|d| d.all? {(-3..-1) === _1} || d.all? {(1..3) === _1}} 
end

# Checks if a whole report is safe by passing each option to option_safe?
def safe?(report)
  options(report).any? {option_safe? _1}
end

p ARGF.count { safe? _1.split.map(&:to_i) }
