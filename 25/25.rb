#!/usr/bin/env ruby

class Door

  attr_reader :keys, :locks
  def initialize(io)
    @keys = []
    @locks = []
    while (pat = 7.times.map {io.gets&.chomp}.compact).length == 7
      load(pat)
      io.gets
    end
  end

  def load(pat)
    if pat[0] == '#####'
      # it's a lock
      locks << pat[1..6].map(&:chars).transpose.map {|col| col.count {_1=='#'}}
    else
      # it's a key
      keys << pat[0..5].map(&:chars).transpose.map {|col| col.count {_1=='#'}}
    end
  end

  # Count the number of key/lock pairs that fit
  def fits
    n = 0
    keys.product(locks) {|k,l| n+=1 if fit? k,l}
    n
  end

  def fit?(key,lock)
    key.zip(lock).all? {_1+_2 < 6}
  end

end

d = Door.new(ARGF)
p d.fits
