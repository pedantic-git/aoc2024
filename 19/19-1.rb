#!/usr/bin/env ruby

towels = ARGF.readline.chomp
re = Regexp.new("\\A(#{towels.split(', ').join('|')})+\\Z".freeze)
p ARGF.count { re.match?(_1) }
