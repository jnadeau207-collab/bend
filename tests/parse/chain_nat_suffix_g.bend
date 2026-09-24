# an operator chain under a ": Nat" suffix: + - * / % < > <= >= spell
# Nat.add, Nat.mul, Nat.is_lt.. at the usual ladder
import Base

def f(a: Nat, b: Nat, c: Nat) -> Nat:
  (a + b * c : Nat)

def main(a: Nat, b: Nat) -> Bool:
  (a < b : Nat)

#|a => b => Cmp.is_lt(Nat.cmp(a, b))
