#!/usr/bin/env ruby

# It's a pair of simultaneous diophantine equations

# ax*a + bx*b = px
# ay*a + by*b = py
# eliminate b by multiplying
# by*ax*a + by*bx*b = by*px
# bx*ay*a + bx*by*b = bx*py
# by*ax*a - bx*ay*a = by*px - bx*py
# (by*ax - bx*ay)a = by*px - bx*py
# a = (by*px - bx*py)/(by*ax - bx*ay)
# bx*b = px - ax*a
# b = (px - ax*a)/bx

def solve(ax, ay, bx, by, px, py)

  # No solution if this doesn't divide
  a,mod = (by*px - bx*py).divmod(by*ax - bx*ay)
  return 0 if mod != 0

  b = (px - ax*a)/bx
  # a costs 3, b costs 1
  a*3+b
end

total_p1 = 0
total_p2 = 0
while (claw = 4.times.map {ARGF.gets}.join) != ""
  ax,ay,bx,by,px,py = claw.scan(/\d+/).map(&:to_i)
  total_p1 += solve(ax,ay,bx,by,px,py)
  total_p2 += solve(ax,ay,bx,by,px+10000000000000,py+10000000000000)
end

p total_p1
p total_p2
