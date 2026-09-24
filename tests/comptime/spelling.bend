# two ~ arguments that are one term spelled two ways (1n+0n is 1n) share
# an instance; two lambdas that differ in a binder's name are two terms
# and two instances, each right
import Base

def add(~n: Nat, x: Nat) -> Nat:
  Nat.add(n, x)

def app(~f: Nat -> Nat, x: Nat) -> Nat:
  f(x)

def main() -> Nat:
  Nat.add(Nat.add(add(~1n+0n, 1n), add(~1n, 1n)), Nat.add(app(~(y => y), 1n), app(~(z => z), 1n)))

#|6n
