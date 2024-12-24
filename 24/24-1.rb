#!/usr/bin/env ruby

require 'pp'
require 'set'

Gate = Struct.new(:a,:b,:op,:out) do
  attr_accessor :open_value

  def value(av, bv)
    self.open_value ||= case op
    when 'AND'
      av && bv
    when 'OR'
      av || bv
    when 'XOR'
      av ^ bv
    end
  end

  def open?
    !!open_value
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
      /(...) (...) (...) -> (...)/.match(line)&.captures&.then {|a,op,b,out| gates << Gate.new(a,b,op,out)}
    end
  end

  # Run until all the gates are open
  def run!
    while registers.keys.all? {|sym| fire!(sym, registers[sym])}
    end
  end

  # Given a symbol and a bool value, set that register and then attempt to
  # open all gates. Returns false if no gates opened - the system is stable
  def fire!(sym, val)
    registers[sym] = val
    # If it starts with a z, set the output too
    output[sym] = val if sym[0] == 'z'
    l = gates.count(&:open?)
    gates.each {|g| open!(g)}
    return gates.count(&:open?) != l
  end

  # Open the given gate by firing it and deleting it from gates
  def open!(gate)
    if registers.key?(gate.a) && registers.key?(gate.b)
      fire!(gate.out, gate.value(registers[gate.a], registers[gate.b]))
    end
  end

end

fm = FruitMonitor.new(ARGF)
fm.run!
pp fm.registers
pp fm.gates
p fm.output
