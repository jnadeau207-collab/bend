# u32_table (#867): a U32 match of dense literals compiles to a table
# whose gaps and clamp carry the default; a bit pattern that binds a
# variable is a default of its own, off the literal walk. odd() takes
# 12 at every odd word, so its table is refused and 3, 5, 7.. must not
# read the root default 13; catch() shadows `_` with a catch-all bit
# pattern, so its table's gaps and clamp must carry 12, not 13.
import Base

law odd:
  for n: U32
  U32

def odd(n):
  match n:
    case 0: 10
    case 1: 11
    case U32{WCon{True{}, r}}: 12
    case _: 13

law catch:
  for n: U32
  U32

def catch(n):
  match n:
    case 0: 10
    case 1: 11
    case U32{WCon{b, r}}: 12
    case _: 13

law walk.odd:
  for +n: Nat
  U32

def walk.odd(n):
  match n:
    case 0n:
      0
    case 1n+p:
      U32.add(odd(U32.from_nat(p)), walk.odd(p))

law walk.catch:
  for +n: Nat
  U32

def walk.catch(n):
  match n:
    case 0n:
      0
    case 1n+p:
      U32.add(catch(U32.from_nat(p)), walk.catch(p))

law main:
  IO(Unit)

def main():
  IO.print(String.append(U32.show(walk.odd(200n)),
    String.append(" ", U32.show(walk.catch(200n)))))

#|2496 2397
