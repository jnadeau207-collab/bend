# a template call in a type is the template's body at its arguments, no
# instance: Pick(~Nat) computes to Nat wherever it stands, and the same
# call in a body is an instance of it
import Base

def Pick(~T: Type) -> Type:
  T

def wrap(x: Pick(~Nat)) -> Pick(~Nat):
  x

def main() -> Pick(~Nat):
  wrap(3n)

#|3n
