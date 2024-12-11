#!/usr/bin/env ruby


def next_stone(n)
  return 1 if n == 0
  digits = Math.log10(n).to_i+1
  return n*2024 if digits % 2 != 0
  oom = 10**(digits/2)
  [n/oom, n%oom]
end

stones = ARGF.readline.split.map(&:to_i)

25.times { stones = stones.flat_map {next_stone _1} }
p stones.length