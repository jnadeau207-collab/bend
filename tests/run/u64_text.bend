# u64 text: show is exact decimal, read its inverse behind a
# whole-string gate: the maximum, zero, a power of two and a halfway
# value round-trip, while overflow, a non-number and the empty string
# answer None
import Base

law seen:
  for m: Maybe<&2, U64>
  String

def seen(m):
  match m:
    case None{}:
      "none"
    case Some{v}:
      U64.show(v)

law main.out:
  String

def main.out():
  a = U64.show(18446744073709551615u64)
  b = U64.show(0u64)
  c = seen(U64.read("123"))
  d = seen(U64.read("18446744073709551616"))
  e = seen(U64.read("hi"))
  f = seen(U64.read(""))
  g = seen(U64.read(U64.show(4294967296u64)))
  h = seen(U64.read(U64.show(9223372036854775808u64)))
  a ++ " " ++ b ++ " " ++ c ++ " " ++ d ++ " " ++ e ++ " " ++ f ++ " " ++ g ++ " " ++ h

law main:
  IO(Unit)

def main():
  IO.print(main.out())

#|18446744073709551615 0 123 none none none 4294967296 9223372036854775808
