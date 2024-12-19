#!/usr/bin/env ruby
p %r{\A(#{ARGF.gets.gsub(', ','|')})+\Z}.then {|r| ARGF.count { r=~_1 }}
