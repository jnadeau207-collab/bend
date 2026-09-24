# an instance is its template to the checker: a call is typed by the
# generic type applied to its arguments (fold(Nat.add, xs, a)) while the
# text around it names the instance (fold~0), so term_wnf reads fold~0
# as fold and the two meet on an open xs
import Base

def fold(~op: Nat -> Nat -> Nat, xs: List<Nat>, acc: Nat) -> Nat:
  match xs:
    case []:
      acc
    case h <> t:
      fold(~op, t, op(acc, h))

def fold_id(~op: Nat -> Nat -> Nat, xs: List<Nat>, +a: Nat) -> {fold(~op, xs, a) == fold(~op, xs, a) : Nat}:
  {==}

def use(xs: List<Nat>, +a: Nat) -> {fold(~Nat.add, xs, a) == fold(~Nat.add, xs, a) : Nat}:
  fold_id(~Nat.add, xs, a)

def main() -> Nat:
  fold(~Nat.add, [1n, 2n], 3n)

#|6n
