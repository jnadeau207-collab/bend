# the module's Nat.add reaches its importer as L.Nat.add, typed as it
# declared (Bool), beside Base's Nat.add
import Base
import ./shadow_lib.bend as L

def main() -> IO(Unit):
  IO.print(Bool.show(L.Nat.add(1n, 2n)))

#|True
