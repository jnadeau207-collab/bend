# a redex whose body is itself a redex: (x => (y => y)(w))(0n)(5n) is
# w(5n) by two beta steps, and term_higher steps at a bare lambda head
# alone, never through an application, so the inner (y => y) takes w
# and not 5n. once a head finder peeled applications too, and the
# checker elaborated it to 5n while the interpreter meant w(5n)
import Base

def w(b: Nat) -> Nat:
  1n+b

def lemma() -> {(x => (y => y)(w))(0n)(5n) == 6n : Nat}:
  {==}

def main() -> Nat:
  (x => (y => y)(w))(0n)(5n)

#|6n
