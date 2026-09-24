# a law takes ~ parameters: its fill checks once with f an opaque
# constant, and each closed call mints an instance (twice~0, twice~1)
# that declares the law's type and compiles the fill's text with f bound
import Base

law twice:
  for ~f: Nat -> Nat
  for x: Nat
  Nat

def twice(f, x):
  f(f(x))

def main() -> IO(Unit):
  a = twice(~(n => 1n+n), 1n)
  b = twice(~(n => Nat.mul(n, 3n)), 2n)
  IO.print(Nat.show(Nat.add(a, b)))

#|21
