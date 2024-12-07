#!/usr/bin/env ruby

class Equation
  attr_reader :test, :operands

  def initialize(line)
    line.match /(\d+): (.*)/
    @test = $1.to_i
    @operands = $2.split.map(&:to_i)
  end

  # Is this equation valid using any of the operator chains?
  def valid?
    possible_operators.each do |stack|
      return true if operands.reduce {_1.send(stack.shift, _2)} == test
    end
    return false
  end

  # Return all the possible operator chains for an Equation of this length
  def possible_operators
    %i[+ *].repeated_permutation(operands.length - 1)
  end

end

p ARGF.sum {Equation.new(_1).then {|e| e.valid? ? e.test : 0}}
