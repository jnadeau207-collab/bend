# a module with two templates around its own Nat.add: F, above it, names
# Base's Nat.add (a name resolves against the book so far), and G, below
# it, names the module's. alone, in the root namespace, the def is a
# duplicate of Base's Nat.add
import Base

def F(~n: Nat, x: Nat) -> Nat:
  Nat.add(n, x)

def Nat.add(a: Nat, b: Nat) -> Nat:
  0n

def G(~n: Nat, x: Nat) -> Nat:
  Nat.add(n, x)

#|Error:
#|- expected : a fresh name (duplicate declaration: Nat.add)
#|- observed : '('
#|Location:
#| 9 |
#|10>| def Nat.add(a: Nat, b: Nat) -> Nat:
#|11 |   0n
#|exit 1
