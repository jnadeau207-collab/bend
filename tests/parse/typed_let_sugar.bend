# a typed let, `x : T = v`, binds x to {v : T}: the annotation is checked
# (a reply may end in `: T` too, as a group's annotation)
import Base

def main() -> U32:
  -n : Nat = 5n
  z : U32 = 30
  (x : U32 = 1; y : U32 = 2; z + x + y : U32)

#|33
