#!/usr/bin/env ruby

require 'pry'

class Mem

  attr_reader :seed
  def initialize(seed)
    @seed = seed
  end

  MOD = 2**24

  # Generate the seq'th number in the random sequence
  def rand(seq)
    i = seed
    seq.times { i = rand_next(i) }
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

p ARGF.sum { Mem.new(_1.to_i).rand(2000) }
