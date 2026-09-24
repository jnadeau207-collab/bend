# a template whose type names another template applied to its own ~
# parameter: the instance use~0 declares the generic type, whose Pick(~T)
# is an open reference, legal in a type (it computes by the generic body)
import Base

def Pick(~T: Type) -> Type:
  T

def use(~T: Type, x: Pick(~T)) -> Pick(~T):
  x

def main() -> IO(Unit):
  IO.print(Nat.show(use(~Nat, 5n)))

#|5
