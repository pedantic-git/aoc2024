#!/usr/bin/env ruby

class Cpu
  
  INSTRUCTIONS = %i[adv bxl bst jnz bxc out bdv cdv]

  def initialize(a, b, c, i)
    @pc = 0
    @a = a
    @b = b
    @c = c
    @i = i
    @output = []
  end

  def run!
    public_send(INSTRUCTIONS[@i[@pc]]) while @i[@pc]
    @output
  end

  def adv
    @a >>= combo_operand
  end

  def bxl
    @b ^= literal_operand 
  end

  def bst
    @b = combo_operand % 8
  end

  def jnz
    literal_operand.then {@pc = _1 unless @a == 0}
  end

  def bxc
    @b ^= @c
    literal_operand
  end

  def out
    @output << combo_operand % 8
  end

  def bdv
    @b = @a >> combo_operand
  end

  def cdv
    @c = @a >> combo_operand
  end

  private

  def literal_operand
    @i[@pc+1].tap {@pc +=2}
  end

  def combo_operand
    case lo = literal_operand
    when 4
      @a
    when 5
      @b
    when 6
      @c
    when 7
      fail "Error"
    else
      lo
    end
  end
  
end

prog = /Program: (.*)/.match(ARGF.read)[1].split(',').map(&:to_i)

# First, find all the values of A up to 11 bits (3 + 8, the maximum c
# can shift by)
vals = (0..7).inject({}) do |h,n|
  h.update(n => (0..2047).select {|a| Cpu.new(a, 0, 0, prog).run!.last == n})
end

# For each number in the program, find a value for a that outputs it and
# prior numbers
possible_a = vals[prog.shift]
prog.each_with_index do |n,i|
  p [n,i]
  i -= 1 # we've shifted one off so the indexes are off by one

  new_poss = possible_a.product(vals[n]).map {|r,l| (l << 3*i) | r}
  p new_poss.length
  # possible_a = new_poss.dup
  # p possible_a
end
#p possible_a
