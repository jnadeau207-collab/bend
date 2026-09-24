# a law with ~ parameters is proved once and used at two instances: comm3
# rewrites with its hypothesis comm twice (an opaque constant, so no usage
# is spent), then U32.add with base's U32.add_comm and both with a proof
# by computation each get a theorem from the one proof
import Base

law comm3:
  for ~op: U32 -> U32 -> U32
  for ~comm: @x: U32 -> @y: U32 -> {op(x, y) == op(y, x) : U32}
  for +a: U32
  for +b: U32
  for +c: U32
  {op(op(a, b), c) == op(c, op(b, a)) : U32}

def comm3(op, comm, a, b, c):
  %comm(b, a) : {op(_, c) == op(c, op(b, a)) : U32}
  %comm(c, op(b, a)) : {_ == op(c, op(b, a)) : U32}
  {==}

def both(x: U32, y: U32) -> U32:
  0

def both_comm(x: U32, y: U32) -> {both(x, y) == both(y, x) : U32}:
  {==}

law main:
  {U32.add(U32.add(1, 2), 3) == U32.add(3, U32.add(2, 1)) : U32}
  & {both(both(1, 2), 3) == both(3, both(2, 1)) : U32}

def main():
  (comm3(~U32.add, ~U32.add_comm, 1, 2, 3), comm3(~both, ~both_comm, 1, 2, 3))

#|({==}, {==})
