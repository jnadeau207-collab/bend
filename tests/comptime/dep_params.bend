# dependent ~ parameters: a later one's type names an earlier one (a: A),
# so the instance's type is the generic one at both, and x : Nat
import Base

def Fill(~A: Type, ~a: A, x: A) -> (A & A):
  (a, x)

def main() -> (Nat & Nat):
  Fill(~Nat, ~1n, 2n)

#|(1n, 2n)
