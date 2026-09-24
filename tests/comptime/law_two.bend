# a law with two ~ clauses, filled with a name for each: the instance at
# a lambda and a def is the fill's body at both
import Base

def inc(n: Nat) -> Nat:
  (1n + n : Nat)

law F:
  for ~f: (Nat -> Nat) -> Nat
  for ~g: Nat -> Nat
  Nat

def F(f, g):
  f(g)

def main() -> Nat:
  F(~(h => h(1n)), ~inc)

#|2n
