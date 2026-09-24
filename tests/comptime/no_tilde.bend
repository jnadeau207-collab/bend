# a call may omit a ~: the arguments bind by position, as an erased (-)
# argument does, so the instance is app's body at Nat.add(1n)
import Base

def app(~f: Nat -> Nat, x: Nat) -> Nat:
  f(x)

def main() -> Nat:
  app(Nat.add(1n), 3n)

#|4n
