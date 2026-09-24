# an @unsafe template: its generic check and its instance carry the mark
# (the self-call skips descent), and the verdict names loop and main, the
# instance being loop's
import Base

@unsafe
def loop(~f: Nat -> Nat, x: Nat) -> Nat:
  match x:
    case 0n:
      0n
    case 1n+p:
      f(loop(~f, p))

def main() -> IO(Unit):
  IO.print(Nat.show(loop(~(n => 1n+n), 3n)))

#|3
