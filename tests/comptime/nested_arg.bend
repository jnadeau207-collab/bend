# a ~ argument that is a lambda whose body calls a template at closed ~
# arguments, and a ~ argument that is a template applied to its own ~
# arguments: both are closed terms, and each inner call is an instance
# minted while the outer instance checks
import Base

def add(~n: Nat, x: Nat) -> Nat:
  Nat.add(n, x)

def app(~f: Nat -> Nat, x: Nat) -> Nat:
  f(x)

def main() -> Nat:
  Nat.add(app(~(y => add(~1n, y)), 1n), app(~add(~10n), 1n))

#|13n
