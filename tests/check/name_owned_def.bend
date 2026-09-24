# the compiler applies a closure through a def it synthesizes, named
# Clo.apply. once a user def at that name was never called: the lane
# ran the closure instead, so a checked False{} came back True{}
import Base

def Clo.apply(f: U32 -> Bool, x: U32) -> Bool:
  False{}

def yes(x: U32) -> Bool:
  True{}

def main() -> Bool:
  Clo.apply(yes, 0)

#|Error: Clo.apply is a name the compiler encodes itself: name yours apart
#|exit 1
