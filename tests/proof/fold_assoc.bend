# a lemma about a template, proved once by induction with the law once
# per step (#848): fold_assoc is stated over any op with an associativity
# law, its fill checks once with op and assoc opaque constants, and it
# rides at two structures: on literals in main, and on an open list in
# use, where the call's generic type meets the instance names in the text
import Base

def fold(~op: Nat -> Nat -> Nat, xs: List<Nat>, acc: Nat) -> Nat:
  match xs:
    case []:
      acc
    case h <> t:
      fold(~op, t, op(acc, h))

law fold_assoc:
  for ~op: Nat -> Nat -> Nat
  for ~assoc: @x: Nat -> @y: Nat -> @z: Nat -> {op(op(x, y), z) == op(x, op(y, z)) : Nat}
  for xs: List<Nat>
  for +a: Nat
  for +b: Nat
  {fold(~op, xs, op(a, b)) == op(a, fold(~op, xs, b)) : Nat}

def fold_assoc(op, assoc, xs, a, b):
  match xs:
    case []:
      {==}
    case +h <> t:
      %Equal.sym(Nat, op(op(a, b), h), op(a, op(b, h)), assoc(a, b, h)) : {fold(~op, t, _) == op(a, fold(~op, t, op(b, h))) : Nat}
      fold_assoc(~op, ~assoc, t, a, op(b, h))

def add_assoc(x: Nat, y: Nat, z: Nat) -> {Nat.add(Nat.add(x, y), z) == Nat.add(x, Nat.add(y, z)) : Nat}:
  match x:
    case 0n:
      {==}
    case 1n+p:
      %add_assoc(p, y, z) : {1n+Nat.add(Nat.add(p, y), z) == 1n+_ : Nat}
      {==}

def first(x: Nat, y: Nat) -> Nat:
  x

def first_assoc(x: Nat, y: Nat, z: Nat) -> {first(first(x, y), z) == first(x, first(y, z)) : Nat}:
  {==}

def use(xs: List<Nat>, +a: Nat, +b: Nat) -> {fold(~Nat.add, xs, Nat.add(a, b)) == Nat.add(a, fold(~Nat.add, xs, b)) : Nat}:
  fold_assoc(~Nat.add, ~add_assoc, xs, a, b)

law main:
  {fold(~Nat.add, [1n, 2n], Nat.add(3n, 4n)) == Nat.add(3n, fold(~Nat.add, [1n, 2n], 4n)) : Nat}
  & {fold(~first, [1n, 2n], first(3n, 4n)) == first(3n, fold(~first, [1n, 2n], 4n)) : Nat}

def main():
  (fold_assoc(~Nat.add, ~add_assoc, [1n, 2n], 3n, 4n), fold_assoc(~first, ~first_assoc, [1n, 2n], 3n, 4n))

#|({==}, {==})
