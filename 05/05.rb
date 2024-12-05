#!/usr/bin/env ruby

require 'set'

class SleighManual
  attr_accessor :rules, :updates

  def initialize(io)
    @rules = Set.new
    @updates = []
    load(io)
  end

  def sort_update(update)
    update.sort do |a,b|
      if @rules === [a,b]
        -1
      elsif @rules === [b,a]
        1
      else
        0
      end
    end
  end

  def update_sorted?(update)
    sort_update(update) == update
  end

  # Return only the updates that are sorted
  def sorted_updates
    updates.select {update_sorted? _1}
  end

  # And only the unsorted updates
  def unsorted_updates
    updates.reject {update_sorted? _1}
  end

  # Get the middle page of a given update
  def middle_page(update)
    update[update.length / 2]
  end

  private

  def load(io)
    io.each do |line|
      case line
      when /\|/
        rules << line.split('|').map(&:to_i)
      when /,/
        updates << line.split(',').map(&:to_i)
      end
    end
  end
end

sm = SleighManual.new(ARGF)
p sm.sorted_updates.sum {sm.middle_page _1}
# This is hideously inefficient - would benefit from update being made into a
# class in its own right
p sm.unsorted_updates.sum {sm.middle_page sm.sort_update(_1)}