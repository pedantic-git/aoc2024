#!/usr/bin/env ruby

@towels = ARGF.readline.chomp.split(', ').sort_by(&:length).reverse
re = Regexp.new("\\A(#{@towels.join('|')})+\\Z".freeze)

def n_combinations(pattern)
  # Find all the matching prefixes
  prefixes = @towels.select {pattern.start_with? _1}
  # Count the prefixes that end the string and recurse with the rest
  ends, conts = prefixes.partition { _1.length == pattern.length }
  ends.length + conts.sum { n_combinations(pattern[_1.length..-1]) }
end

p ARGF.select {re.match? _1}.sum {|pattern| n_combinations(pattern.chomp) }