#!/usr/bin/env ruby

require 'pp'

class Mem

  attr_accessor :seed
  attr_reader :changes

  MOD = 2**24

  def initialize
    @changes = {}
    @changes_seen = {}
  end

  # Generate the seq'th number in the random sequence
  def rand(seq)
    i = seed
    last_five = [i%10]
    seq.times do
      i = rand_next(i)
      last_five = last_five.last(4) << i%10
      key = last_five.each_cons(2).map {_2-_1}
      next if key.length < 4
      changes[key] ||= {}
      # Only the first time this happens
      changes[key][seed] ||= last_five[-1]
    end
    i
  end

  # Given i, calculate the next value in the sequence
  def rand_next(i)
    mix_and_prune(11, mix_and_prune(-5, mix_and_prune(6, i)))
  end

  def mix_and_prune(power, i)
    (i ^ i<<power) % MOD
  end

end

m = Mem.new
p ARGF.sum { m.seed = _1.to_i; m.rand(2000) }
p m.changes.max_by {|k,v| v.values.sum}.then {|k,v| v.values.sum}
