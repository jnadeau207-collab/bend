# a bounded loop whose fuel is a literal is a loop, not 40 copies of its
# body: the fold's fuel is the size of what an unfold adds, so a wide body
# stops it at once, while a small one still folds (#886). The call sits in
# an expression position: a tail call never folds.
import Base

def step(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32,
    +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32,
    +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32,
    +x20: U32, +x21: U32, +x22: U32, +x23: U32) -> U32:
  ((((((((((((((((((((((((x0 + x1 : U32) + x2 : U32) + x3 : U32) + x4 : U32)
    + x5 : U32) + x6 : U32) + x7 : U32) + x8 : U32) + x9 : U32) + x10 : U32)
    + x11 : U32) + x12 : U32) + x13 : U32) + x14 : U32) + x15 : U32)
    + x16 : U32) + x17 : U32) + x18 : U32) + x19 : U32) + x20 : U32)
    + x21 : U32) + x22 : U32) + x23 : U32) * 3 : U32)

def spin(n: Nat, +x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32,
    +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32,
    +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32,
    +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32) -> U32:
  match n:
    case 0n:
      step(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14,
        x15, x16, x17, x18, x19, x20, x21, x22, x23)
    case 1n+p:
      spin(p, (x0 + 1 : U32), (x1 + x0 : U32), (x2 + x1 : U32),
        (x3 + x2 : U32), (x4 + x3 : U32), (x5 + x4 : U32), (x6 + x5 : U32),
        (x7 + x6 : U32), (x8 + x7 : U32), (x9 + x8 : U32), (x10 + x9 : U32),
        (x11 + x10 : U32), (x12 + x11 : U32), (x13 + x12 : U32),
        (x14 + x13 : U32), (x15 + x14 : U32), (x16 + x15 : U32),
        (x17 + x16 : U32), (x18 + x17 : U32), (x19 + x18 : U32),
        (x20 + x19 : U32), (x21 + x20 : U32), (x22 + x21 : U32),
        (x23 + x22 : U32))

def main() -> U32:
  (spin(40n, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    19, 20, 21, 22, 23, 24) + 0 : U32)

#|3929243529
