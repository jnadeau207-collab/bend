# ( .. : T) names every operator of the operator expression it annotates:
# the whole chain, through grouping parens and && / ||; an index's U32 and
# an array literal's T name their own chains the same way
import Base

def at(r: Array<U32> & U32) -> U32:
  (xs, x) = r
  x

def main() -> U32:
  xs = [1 + 2 : U32*4n]
  a  = (1 + (2 * 3) - 1 : U32)
  b  = Bool.to_u32(((1 < 2) && (2 < 3) : U32))
  (a + b + at(xs[1 + 1]) : U32)

#|10
