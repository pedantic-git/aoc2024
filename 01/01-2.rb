#!/usr/bin/env ruby

p ARGF.map {_1.split.map(&:to_i)}.transpose.then {|l,r| t = r.tally; l.map {_1 * (t[_1] || 0)}.sum}
