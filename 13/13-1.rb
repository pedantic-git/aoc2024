#!/usr/bin/env ruby

def extended_gcd(a,b)
  return [a,1,0] if b==0
  d, p, q = extended_gcd(b, a%b)
  [d, q, p-q*(a/b)]
end

# Finds a single valid solution to the diophantine equation ax + by = c
def diophantine(a,b,c)
  d,x,y = extended_gcd(a,b)
  r = c/d
  [r*x, r*y]
end

# Shift the given solution until the smallest positive x is found
def solution_with_smallest_positive_x(x,y,a,b)
  # This is wrong - see https://cp-algorithms.com/algebra/linear-diophantine-equation.html
  if x < 0
    [x+b, y-a].then {|nx,ny| return nx > 0 ? [nx, ny] : solution_with_smallest_positive_x(nx, ny, a, b)}
  else
    [x-b, y+a].then {|nx,ny| return nx < 0 ? [x,y] : solution_with_smallest_positive_x(nx, ny, a, b)}
  end
end

def solve(ax, ay, bx, by, px, py)
  # This is a linear diophantine equation (A and B are the number of times you
  # need to press A and B)
  # ax*A + bx*B = px : ay*A + by*B = py
  # ax*A + bx*B - px = ay*A + by*B - py
  # ax*A - ay*A + bx*B - by*B = px - py
  # (ax-ay)*A + (bx-by)*B = px-py
  diophantine(ax-ay, bx-by, px-py)
end

p solve(94, 34, 22, 67, 8400, 5400)
p solve(26, 66, 67, 21, 12758, 12176)
