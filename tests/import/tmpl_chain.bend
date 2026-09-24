# instances of another module's templates: quad at a lambda mints twice's
# instance from the importer's call, and count at 5n mints count at 1n
# from its own body
import Base
import ./tmpl_chain_lib.bend as M

def main() -> Nat:
  Nat.add(M.quad(~(y => Nat.add(y, 2n)), 0n), M.count(~5n, 2n))

#|15n
