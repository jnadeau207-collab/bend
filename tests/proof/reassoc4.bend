# theorems over an abstract structure (#848): reassoc4 is stated once over
# any op with an associativity law, and its proof applies the hypothesis
# assoc twice. assoc is a ~ parameter, so the fill checks once with assoc
# an opaque constant (a reference costs no usage, so a proof may use it as
# often as it needs), and each instance rides the one proof: Nat.add with
# its inductive add_assoc, first with a proof by computation
import Base

law reassoc4:
  for ~op: Nat -> Nat -> Nat
  for ~assoc: @x: Nat -> @y: Nat -> @z: Nat -> {op(op(x, y), z) == op(x, op(y, z)) : Nat}
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for +d: Nat
  {op(op(op(a, b), c), d) == op(a, op(b, op(c, d))) : Nat}

def reassoc4(op, assoc, a, b, c, d):
  %assoc(a, b, op(c, d)) : {op(op(op(a, b), c), d) == _ : Nat}
  %Equal.sym(Nat, op(op(op(a, b), c), d), op(op(a, b), op(c, d)), assoc(op(a, b), c, d)) : {_ == op(op(a, b), op(c, d)) : Nat}
  {==}

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

law main:
  {Nat.add(Nat.add(Nat.add(1n, 2n), 3n), 4n) == Nat.add(1n, Nat.add(2n, Nat.add(3n, 4n))) : Nat}
  & {first(first(first(1n, 2n), 3n), 4n) == first(1n, first(2n, first(3n, 4n))) : Nat}

def main():
  (reassoc4(~Nat.add, ~add_assoc, 1n, 2n, 3n, 4n), reassoc4(~first, ~first_assoc, 1n, 2n, 3n, 4n))

#|({==}, {==})
