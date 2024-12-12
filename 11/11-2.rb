#!/usr/bin/env ruby

@times = 75
@count = 0

Stone = Struct.new(:n, :turn) do
  def inspect
    "#{n}(#{turn})"
  end
end

stones = ARGF.readline.split(' ').map {Stone.new(_1.to_i, 1)}

def process!
  stone = @stack.shift
  stone.turn.upto(@times) do |turn|
    if stone.n == 0
      stone.n = 1
      next
    end
    digits = Math.log10(stone.n).to_i+1
    if digits.even?
      mag = 10**(digits/2)
      # add the second half onto the stack, remembering what turn it is
      @stack << Stone.new(stone.n % mag, turn + 1)
      # n is the first half
      stone.n /= mag
    else
      stone.n *= 2024
    end
  end
  @count += 1
end

stones.each do |stone|
  p stone.n
  @stack = [stone]
  until @stack.empty?
    process!
  end
end

p @count
