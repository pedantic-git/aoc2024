#!/usr/bin/env ruby

require 'pp'
require 'set'

Gate = Struct.new(:a,:b,:op,:out) do
  attr_accessor :open_value

  def value(av, bv)
    @open_value ||= case op
    when 'AND'
      av && bv
    when 'OR'
      av || bv
    when 'XOR'
      av ^ bv
    end
  end

  def open?
    !open_value.nil?
  end
end


class FruitMonitor

  attr_accessor :registers, :gates, :output
  def initialize(io)
    @registers = {}
    @gates = Set.new
    @output = {}
    io.each do |line|
      /(...): (\d)/.match(line)&.captures&.then {|r,v| registers[r] = (v=='1')}
      /(...) (...?) (...) -> (...)/.match(line)&.captures&.then {|a,op,b,out| gates << Gate.new(a,b,op,out)}
    end
  end

  # tick until all the gates are open
  def run!
    while tick!
    end
  end

  # process gates and return true if any opened for the first time
  def tick!
    gates.map {process_gate _1}.any?
  end

  # Process the current gate if possible and return true if this is the
  # first time it opened
  def process_gate(gate)
    gate_was_open = gate.open?
    if registers.key?(gate.a) && registers.key?(gate.b)
      registers[gate.out] = gate.value(registers[gate.a], registers[gate.b])
      if gate.out[0] == 'z'
        output[gate.out] = registers[gate.out]
      end
      return !gate_was_open
    end
    false
  end

  # The binary value of all the z registers
  def value
    # This could be _much_ more efficient than using strings but it's probably
    # fine
    output.keys.sort.reverse.map {|k| output[k] ? '1' : '0'}.join.to_i(2)
  end

end

fm = FruitMonitor.new(ARGF)
fm.run!
p fm.value
