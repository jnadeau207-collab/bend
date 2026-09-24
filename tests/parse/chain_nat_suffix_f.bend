# an operator chain under a ": Nat" suffix: + - * / % < > <= >= spell
# Nat.add, Nat.mul, Nat.is_lt.. at the usual ladder
import Base

def main(a: Nat, b: Nat, c: Nat) -> Nat:
  (a + b * c : Nat)

def g(a: Nat, b: Nat) -> Bool:
  (a < b : Nat)

#|a => b => c => Nat.add(a, Nat.mul(b, c))
