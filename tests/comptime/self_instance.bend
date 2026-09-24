# a template that calls itself at closed ~ arguments mints its instance
# while its own body parses, before its generic def has a body: the
# instance is not a fill of an unfilled law, it is f's text at n = 0n
import Base

def f(~n: Nat, x: Nat) -> Nat:
  match x:
    case 0n:
      n
    case 1n+p:
      Nat.add(n, f(~0n, p))

def main() -> IO(Unit):
  IO.print(Nat.show(f(~2n, 5n)))

#|2
