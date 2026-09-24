# a ( .. : T) annotates the body of the let chain it holds: the body is
# the expression's value, so its operators take T. a tuple's elements are
# each their own term, so (a + b, c + d : T) annotates the last alone,
# and the first needs its own parens
import Base

def f(a: Nat, b: Nat) -> Nat:
  (x = a; y = b; x + y : Nat)

def g() -> (Nat & Nat):
  ((1n + 2n : Nat), 3n + 4n : Nat)

def main() -> (Nat & (Nat & Nat)):
  (f(1n, 2n), g())

#|(3n, 3n, 7n)
