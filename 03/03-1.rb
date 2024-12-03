#!/usr/bin/env ruby

p ARGF.read.scan(%r{mul\((\d+),(\d+)\)}).map {_1.map(&:to_i).reduce(:*)}.sum