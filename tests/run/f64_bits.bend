# F64 is its 64 bits (F64_CONTRACT.md): signed zeros, subnormal edges,
# the normal extremes, both infinities, quiet and signaling NaNs with
# payloads, a negative NaN, all ones and a tag-looking word each ride a
# boxing generic, an Array swap, a closure and a fork back to their exact
# bits (16 kept per line); then each class mask (bits: nan, inf, finite,
# zero, subnormal, normal, sign), a hash of neg, abs and copysign(_, -1),
# of F32.to_f64 over fourteen F32 edges (a NaN goes canonical, 2^51 quiet)
# and of U32.to_f64. The expected values are Python's struct.
import Base

def lo(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      0
    case 2:
      1
    case 3:
      4294967295
    case 4:
      0
    case 5:
      0
    case 6:
      4294967295
    case 7:
      0
    case 8:
      0
    case 9:
      0
    case 10:
      1
    case 11:
      3735928559
    case 12:
      1
    case 13:
      4294967295
    case 14:
      4660
    case _:
      1413754136

def hi(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      2147483648
    case 2:
      0
    case 3:
      1048575
    case 4:
      1048576
    case 5:
      1072693248
    case 6:
      2146435071
    case 7:
      2146435072
    case 8:
      4293918720
    case 9:
      2146959360
    case 10:
      2146435072
    case 11:
      2146435072
    case 12:
      4294443008
    case 13:
      4294967295
    case 14:
      33554432
    case _:
      3221823995

def f32(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      2147483648
    case 2:
      1
    case 3:
      8388607
    case 4:
      8388608
    case 5:
      1065353216
    case 6:
      1036831949
    case 7:
      2139095039
    case 8:
      2139095040
    case 9:
      4286578688
    case 10:
      2143289344
    case 11:
      2139095041
    case 12:
      4290772993
    case _:
      3212836864

def u32(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      1
    case 2:
      2
    case 3:
      3
    case 4:
      2147483648
    case 5:
      4294967295
    case 6:
      12345
    case _:
      2147483649

def pat(+n: U32) -> F64:
  F64.from_bits(U64.join(lo(n), hi(n)))

def kept(+n: U32, +a: F64) -> U32:
  +b = F64.bits(a)
  Bool.to_u32(Bool.and(U32.is_eq(U64.lo(b), lo(n)), U32.is_eq(U64.hi(b), hi(n))))

def poly(-A: Type, x: A) -> A:
  x

def snd(r: Array<F64> & F64) -> F64:
  (a, x) = r
  x

def app(f: U32 -> F64, a: U32) -> F64:
  f(a)

def fork(x: F64) -> F64:
  a b = poly(F64, x) F64.nan()
  a

def carry(k: U32, x: F64) -> F64:
  match k:
    case 0:
      poly(F64, x)
    case 1:
      snd(Array.swap(F64, Array.new(F64, 2n, x), 1, F64.nan()))
    case 2:
      app(u => x, 0)
    case _:
      fork(x)

def as_f32(u: U32) -> F32:
  U32{w} = u
  F32{w}

def bit(acc: U32, b: Bool) -> U32:
  U32.add(U32.mul(acc, 2), Bool.to_u32(b))

def mask(+a: F64) -> U32:
  bit(bit(bit(bit(bit(bit(Bool.to_u32(F64.is_nan(a)), F64.is_inf(a)),
    F64.is_finite(a)), F64.is_zero(a)), F64.is_subnormal(a)),
    F64.is_normal(a)), F64.sign(a))

def step(+h: U32, w: U32) -> U32:
  U32.mul(U32.xor(U32.or(U32.shln(h, 5n), U32.shrn(h, 27n)), w), 2654435761)

def mix(h: U32, +x: U64) -> U32:
  step(step(h, U64.lo(x)), U64.hi(x))

def signs(+a: F64, h: U32) -> U32:
  +m = F64.from_bits(U64.join(0, 3220176896))
  mix(mix(mix(h, F64.bits(F64.neg(a))), F64.bits(F64.abs(a))),
    F64.bits(F64.copysign(a, m)))

def one(g: U32, k: U32, +i: U32, r: U32) -> U32:
  match g:
    case 0:
      U32.add(kept(i, carry(k, pat(i))), r)
    case 1:
      signs(pat(i), r)
    case 2:
      mix(r, F64.bits(F32.to_f64(as_f32(f32(i)))))
    case _:
      mix(r, F64.bits(U32.to_f64(u32(i))))

def walk(+g: U32, +k: U32, +n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      one(g, k, U32.from_nat(p), walk(g, k, p))

def masks(+n: Nat) -> String:
  match n:
    case 0n:
      ""
    case 1n+p:
      masks(p) ++ U32.show(mask(pat(U32.from_nat(p)))) ++ " "

def main() -> IO(Unit):
  IO.print(U32.show(walk(0, 0, 16n)) ++ " " ++ U32.show(walk(0, 1, 16n))
    ++ " " ++ U32.show(walk(0, 2, 16n)) ++ " " ++ U32.show(walk(0, 3, 16n))
    ++ "\n" ++ masks(16n) ++ "\n" ++ U32.show(walk(1, 0, 16n)) ++ " "
    ++ U32.show(walk(2, 0, 14n)) ++ " " ++ U32.show(walk(3, 0, 8n)))

#|16 16 16 16
#|24 25 20 20 18 18 18 32 33 64 64 64 65 65 18 19
#|2864268918 4098403399 265452751
