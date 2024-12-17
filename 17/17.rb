#!/usr/bin/env ruby

class Cpu
  
  INSTRUCTIONS = %i[adv bxl bst jnz bxc out bdv cdv]

  def initialize(str)
    @pc = 0
    @a = /Register A: (\d+)/.match(str)[1].to_i
    @b = /Register B: (\d+)/.match(str)[1].to_i
    @c = /Register B: (\d+)/.match(str)[1].to_i
    @i = /Program: (.*)/.match(str)[1].split(',').map(&:to_i)
    @output = []
  end

  def run!
    public_send(INSTRUCTIONS[@i[@pc]]) while @i[@pc]
    @output.join(',')
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

c = Cpu.new(ARGF.read)
puts c.run!
