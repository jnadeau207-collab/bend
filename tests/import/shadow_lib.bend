# a module def named like a Base def is its own def: its namespace keeps
# it apart, and its type is the one it declares, not Base's. alone, in the
# root namespace, the same text is a duplicate of Base's Nat.add
import Base

def Nat.add(a: Nat, b: Nat) -> Bool:
  True{}

#|Error:
#|- expected : a fresh name (duplicate declaration: Nat.add)
#|- observed : '('
#|Location:
#|5 | 
#|6>| def Nat.add(a: Nat, b: Nat) -> Bool:
#|7 |   True{}
#|exit 1
