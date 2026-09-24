# importing does not contaminate: the module holds an @unsafe def, but
# nothing here names it, so the verdict is clean
import Base
import ./unsafe_lib.bend as L

def keep(n: Nat) -> Nat:
  L.safe(n)

#|All terms check.
