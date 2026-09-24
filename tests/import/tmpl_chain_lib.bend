# a module's template that calls another module template at its own ~
# parameter, and a template that calls itself at a closed ~ argument
import Base

def twice(~f: Nat -> Nat, x: Nat) -> Nat:
  f(f(x))

def quad(~f: Nat -> Nat, x: Nat) -> Nat:
  twice(~f, twice(~f, x))

def count(~n: Nat, x: Nat) -> Nat:
  match x:
    case 0n:
      n
    case 1n+p:
      Nat.add(n, count(~1n, p))

def main() -> Nat:
  Nat.add(quad(~(y => 1n+y), 0n), count(~5n, 2n))

#|11n
