# U64 against exact 64-bit arithmetic: every binary op over all pairs of
# nine words (0, 1, 2^32 - 1, 2^32, 2^53 + 1, 2^63, 2^64 - 1, a mixed one
# and 2^63 + 1), every unary op over each, every shift at 0, 1, 31, 32,
# 63, 64 and 65, each folded into one hash (h = rotl(h, 5) ^ half, times
# an odd constant, over the low then high half: no bit's error cancels). The interpreter runs Base's Word defs, C and JS
# the natives; the expected hashes are Python's.
import Base

def v(n: U32) -> U64:
  match n:
    case 0:
      U64.join(0, 0)
    case 1:
      U64.join(1, 0)
    case 2:
      U64.join(4294967295, 0)
    case 3:
      U64.join(0, 1)
    case 4:
      U64.join(1, 2097152)
    case 5:
      U64.join(0, 2147483648)
    case 6:
      U64.join(4294967295, 4294967295)
    case 7:
      U64.join(2309737967, 19088743)
    case _:
      U64.join(1, 2147483648)

def cmp_u64(c: Cmp) -> U64:
  match c:
    case LT{}:
      U64.from_u32(0)
    case EQ{}:
      U64.from_u32(1)
    case GT{}:
      U64.from_u32(2)

def bin(k: U32, a: U64, b: U64) -> U64:
  match k:
    case 0:
      U64.add(a, b)
    case 1:
      U64.sub(a, b)
    case 2:
      U64.mul(a, b)
    case 3:
      U64.and(a, b)
    case 4:
      U64.or(a, b)
    case 5:
      U64.xor(a, b)
    case 6:
      U64.div(a, b)
    case 7:
      U64.mod(a, b)
    case 8:
      cmp_u64(U64.cmp(a, b))
    case _:
      U64.mul_hi(a, b)

def un(k: U32, a: U64) -> U64:
  match k:
    case 0:
      U64.not(a)
    case 1:
      U64.shl(a)
    case 2:
      U64.shr(a)
    case 3:
      U64.inc(a)
    case 4:
      U64.from_u32(U64.clz(a))
    case _:
      U64.from_u32(Bool.to_u32(U64.is_zero(a)))

def sh(k: U32, a: U64, n: Nat) -> U64:
  match k:
    case 0:
      U64.shln(a, n)
    case 1:
      U64.shrn(a, n)
    case _:
      U64.shr_jam(a, n)

def cnt(n: U32) -> Nat:
  match n:
    case 0:
      0n
    case 1:
      1n
    case 2:
      31n
    case 3:
      32n
    case 4:
      63n
    case 5:
      64n
    case _:
      65n

def step(+h: U32, w: U32) -> U32:
  U32.mul(U32.xor(U32.or(U32.shln(h, 5n), U32.shrn(h, 27n)), w), 2654435761)

def mix(h: U32, +x: U64) -> U32:
  step(step(h, U64.lo(x)), U64.hi(x))

def fold(+k: U32, +i: Nat, +h: U32) -> U32:
  match i:
    case 0n:
      h
    case 1n+p:
      +j = U32.from_nat(p)
      +a = U32.div(j, 9)
      +b = U32.mod(j, 9)
      fold(k, p, mix(h, bin(k, v(a), v(b))))

def fold1(+k: U32, +i: Nat, +h: U32) -> U32:
  match i:
    case 0n:
      h
    case 1n+p:
      fold1(k, p, mix(h, un(k, v(U32.from_nat(p)))))

def folds(+k: U32, +i: Nat, +h: U32) -> U32:
  match i:
    case 0n:
      h
    case 1n+p:
      +j = U32.from_nat(p)
      folds(k, p, mix(h, sh(k, v(U32.div(j, 7)), cnt(U32.mod(j, 7)))))

def one(+g: U32, +k: U32) -> U32:
  match g:
    case 0:
      fold(k, 81n, 0)
    case 1:
      fold1(k, 9n, 0)
    case _:
      folds(k, 63n, 0)

def line(+g: U32, +n: Nat) -> String:
  match n:
    case 0n:
      ""
    case 1n+p:
      line(g, p) ++ U32.show(one(g, U32.from_nat(p))) ++ " "

def main() -> IO(Unit):
  IO.print(line(0, 10n) ++ line(1, 6n) ++ line(2, 3n))

#|1462336766 804706259 2183587553 3306560915 4259349406 2445440408 2845166562 931113301 1514895077 1105374277 501669383 2184325798 3123698710 494489156 1802821697 3136787523 3491123835 2615710433 3993330320
