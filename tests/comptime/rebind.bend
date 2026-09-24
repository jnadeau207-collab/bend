# a ~ name is a binder like any other: the let f = .. in the template's
# body shadows it, and the instance at inc never sees inc
import Base

def inc(n: Nat) -> Nat:
  1n+n

def app(~f: Nat -> Nat, x: Nat) -> Nat -> Nat:
  f = Nat.add(x)
  f

def main() -> Nat:
  app(~inc, 10n)(1n)

#|11n
