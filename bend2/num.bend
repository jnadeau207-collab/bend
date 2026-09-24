# Num
# ===
# Base's 64-bit numbers (bend2/docs/F64_CONTRACT.md), read right after
# base.bend as part of Base: U64, then F64 as its bits and its software
# core, the contract's reference and the device lane's code. The core
# stays flat (one binding per let, no bang, self-calls tail-only): the
# device lane spins it, and only flat defs spin.

type U64 is Data:
  U64{data: Word(64n)}

type F64 is Data:
  F64{data: Word(64n)}

def Word.cat(n: Nat, m: Nat, a: Word(n), b: Word(m)) -> Word(Nat.add(n, m)):
  match n a:
    case 0n WNil{}:
      b
    case 1n+p WCon{h, t}:
      WCon{h, Word.cat(p, m, t, b)}

def Word.take(n: Nat, m: Nat, w: Word(Nat.add(n, m))) -> Word(n):
  match n:
    case 0n:
      WNil{}
    case 1n+p:
      match w:
        case WCon{h, t}:
          WCon{h, Word.take(p, m, t)}

def Word.drop(n: Nat, m: Nat, w: Word(Nat.add(n, m))) -> Word(m):
  match n:
    case 0n:
      w
    case 1n+p:
      match w:
        case WCon{h, t}:
          Word.drop(p, m, t)

# U64
# ---

def U64.join(lo: U32, hi: U32) -> U64:
  match lo hi:
    case U32{a} U32{b}:
      U64{Word.cat(32n, 32n, a, b)}

def U64.lo(a: U64) -> U32:
  U64{w} = a
  U32{Word.take(32n, 32n, w)}

def U64.hi(a: U64) -> U32:
  U64{w} = a
  U32{Word.drop(32n, 32n, w)}

def U64.add(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.add(64n, x, y)}

def U64.sub(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.sub(64n, x, y)}

def U64.mul(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.mul(64n, x, y)}

def U64.and(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.and(64n, x, y)}

def U64.or(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.or(64n, x, y)}

def U64.xor(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.xor(64n, x, y)}

def U64.div(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.div(64n, x, y)}

def U64.mod(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.mod(64n, x, y)}

def U64.not(a: U64) -> U64:
  match a:
    case U64{x}:
      U64{Word.not(64n, x)}

def U64.shl(a: U64) -> U64:
  match a:
    case U64{x}:
      U64{Word.shl(64n, x)}

def U64.shr(a: U64) -> U64:
  match a:
    case U64{x}:
      U64{Word.shr(64n, x)}

def U64.inc(a: U64) -> U64:
  match a:
    case U64{x}:
      U64{Word.inc(64n, x)}

def U64.shln(a: U64, n: Nat) -> U64:
  match n:
    case 0n:
      a
    case 1n+p:
      U64.shl(U64.shln(a, p))

def U64.shrn(a: U64, n: Nat) -> U64:
  match n:
    case 0n:
      a
    case 1n+p:
      U64.shr(U64.shrn(a, p))

def U64.cmp(a: U64, b: U64) -> Cmp:
  match a b:
    case U64{x} U64{y}:
      Word.cmp(64n, x, y)

def U64.is_eq(a: U64, b: U64) -> Bool:
  Cmp.is_eq(U64.cmp(a, b))

def U64.is_ne(a: U64, b: U64) -> Bool:
  Bool.not(Cmp.is_eq(U64.cmp(a, b)))

def U64.is_lt(a: U64, b: U64) -> Bool:
  Cmp.is_lt(U64.cmp(a, b))

def U64.is_le(a: U64, b: U64) -> Bool:
  Cmp.is_le(U64.cmp(a, b))

def U64.is_gt(a: U64, b: U64) -> Bool:
  Cmp.is_gt(U64.cmp(a, b))

def U64.is_ge(a: U64, b: U64) -> Bool:
  Cmp.is_ge(U64.cmp(a, b))

def U64.is_zero(a: U64) -> Bool:
  U64.is_eq(a, 0u64)

def U64.from_u32(a: U32) -> U64:
  U64.join(a, 0)

def Word.clz.fin(+p: Nat, b: Bool, +c: Nat) -> Nat:
  Bool.pick(Nat, Bool.and(Nat.is_eq(c, p), Bool.not(b)), 1n+p, c)

# the zeros above the highest set bit (n for a zero word)
def Word.clz(+n: Nat, w: Word(n)) -> Nat:
  match n:
    case 0n:
      0n
    case 1n+p:
      match w:
        case WCon{b, t}:
          Word.clz.fin(p, b, Word.clz(p, t))

def U64.clz(a: U64) -> U32:
  U64{w} = a
  U32.from_nat(Word.clz(64n, w))

# the high 64 bits of the 128-bit product
def U64.mul_hi(a: U64, b: U64) -> U64:
  match a b:
    case U64{x} U64{y}:
      U64{Word.drop(64n, 64n, Word.mul(128n,
        Word.cat(64n, 64n, x, Word.zero(64n)),
        Word.cat(64n, 64n, y, Word.zero(64n))))}

# a >> n, its lowest bit set when a set bit was shifted out (sticky)
def U64.shr_jam(+a: U64, +n: Nat) -> U64:
  +s = U64.shrn(a, n)
  U64.or(s, U64.from_u32(Bool.to_u32(U64.is_ne(U64.shln(s, n), a))))

law U64.show.go:
  for f   : Nat
  for +n  : U64
  for acc : String
  String

def U64.show.fin(g: Nat, acc: String, +n: U64, z: Bool) -> String:
  match z:
    case True{}:
      acc
    case False{}:
      U64.show.go(g, U64.div(n, 10u64),
        SCon{Chr{U64.lo(U64.add(48u64, U64.mod(n, 10u64)))}, acc})

def U64.show.go(f, n, acc):
  match f:
    case 0n:
      acc
    case 1n+g:
      U64.show.fin(g, acc, n, U64.is_zero(n))

def U64.show.if(a: U64, z: Bool) -> String:
  match z:
    case True{}:
      SCon{Chr{48}, SNil{}}
    case False{}:
      U64.show.go(20n, a, SNil{})

def U64.show(a: U64) -> String:
  +b = a
  U64.show.if(b, U64.is_zero(b))

law U64.read.go:
  for s   : String
  for +acc : U64
  Maybe<&2, U64>

def U64.read.if(t: String, n: U64, ok: Bool) -> Maybe<&2, U64>:
  match ok:
    case True{}:
      U64.read.go(t, n)
    case False{}:
      None{}

def U64.read.go(s, acc):
  match s:
    case SNil{}:
      Some{acc}
    case SCon{Chr{x}, t}:
      +n = U64.add(U64.mul(acc, 10u64), U64.sub(U64.from_u32(x), 48u64))
      U64.read.if(t, n, U64.is_eq(U64.div(n, 10u64), acc))

def U64.read(s: String) -> Maybe<&2, U64>:
  match s:
    case SNil{}:
      None{}
    case SCon{h, t}:
      U64.read.go(SCon{h, t}, 0u64)

# F64
# ---
# an IEEE-754 binary64 held as its bits (F64_CONTRACT.md): storage keeps
# every pattern; only arithmetic may canonicalize a NaN

def F64.from_bits(a: U64) -> F64:
  U64{w} = a
  F64{w}

def F64.bits(a: F64) -> U64:
  F64{w} = a
  U64{w}

def F64.inf() -> U64:
  0x7ff0000000000000u64

def F64.nan() -> F64:
  F64.from_bits(0x7ff8000000000000u64)

def F64.mag(a: F64) -> U64:
  U64.and(F64.bits(a), 0x7fffffffffffffffu64)

def F64.sign(a: F64) -> Bool:
  U64.is_ne(U64.shrn(F64.bits(a), 63n), 0u64)

def F64.neg(a: F64) -> F64:
  F64.from_bits(U64.xor(F64.bits(a), 0x8000000000000000u64))

def F64.abs(a: F64) -> F64:
  F64.from_bits(F64.mag(a))

def F64.copysign(a: F64, b: F64) -> F64:
  F64.from_bits(U64.or(F64.mag(a),
    U64.and(F64.bits(b), 0x8000000000000000u64)))

def F64.is_nan(a: F64) -> Bool:
  U64.is_gt(F64.mag(a), F64.inf())

def F64.is_inf(a: F64) -> Bool:
  U64.is_eq(F64.mag(a), F64.inf())

def F64.is_finite(a: F64) -> Bool:
  U64.is_lt(F64.mag(a), F64.inf())

def F64.is_zero(a: F64) -> Bool:
  U64.is_zero(F64.mag(a))

def F64.is_subnormal(a: F64) -> Bool:
  +m = F64.mag(a)
  Bool.and(Bool.not(U64.is_zero(m)), U64.is_lt(m, 0x0010000000000000u64))

def F64.is_normal(a: F64) -> Bool:
  +m = F64.mag(a)
  Bool.and(U64.is_ge(m, 0x0010000000000000u64), U64.is_lt(m, F64.inf()))

# x * 2^(e - 1085) for x < 2^53, exactly: x's top bit lands on the hidden
# bit, which adds the 1 its exponent field needs
def F64.norm(+x: U64, +e: U32) -> F64:
  +z = U64.clz(x)
  F64.from_bits(Bool.pick(U64, U64.is_zero(x), x,
    U64.add(U64.shln(x, U32.to_nat(U32.sub(z, 11))),
      U64.shln(U64.from_u32(U32.sub(e, z)), 52n))))

def U32.to_f64(a: U32) -> F64:
  F64.norm(U64.from_u32(a), 1085)

# exact: a subnormal is its field times 2^-149, a normal gains its hidden
# bit; an infinity keeps its sign, a NaN is the canonical quiet one
def F32.to_f64(f: F32) -> F64:
  F32{w} = f
  +b = {U32{w} : U32}
  +e = U32.and(U32.shrn(b, 23n), 255)
  +m = U32.and(b, 8388607)
  +s = U64.shln(U64.from_u32(U32.shrn(b, 31n)), 63n)
  +x = F64.norm(U64.from_u32(U32.or(m, U32.shln(Bool.to_u32(U32.is_ne(e, 0)),
    23n))), U32.add(935, U32.max(e, 1)))
  Bool.pick(F64, U32.is_eq(e, 255), Bool.pick(F64, U32.is_zero(m),
    F64.from_bits(U64.or(s, F64.inf())), F64.nan()),
    F64.from_bits(U64.or(s, F64.bits(x))))

# F64 arithmetic: the contract's one software core. A finite nonzero
# operand is m * 2^(e - 1075), m in [2^52, 2^53) (a subnormal normalized);
# every result is rounded once, to nearest even, by F64.round.

def U64.bit(b: Bool) -> U64:
  U64.from_u32(Bool.to_u32(b))

def U64.jam(a: U64) -> U64:
  U64.bit(Bool.not(U64.is_zero(a)))

def F64.field(a: F64) -> U32:
  U32.and(U32.shrn(U64.hi(F64.bits(a)), 20n), 2047)

# the significand: its fraction, and the hidden bit of a normal
def F64.x(+a: F64) -> U64:
  U64.or(U64.and(F64.bits(a), 0x000fffffffffffffu64),
    U64.shln(U64.bit(U32.is_ne(F64.field(a), 0)), 52n))

def F64.k(a: F64) -> U32:
  U32.sub(U64.clz(F64.x(a)), 11)

def F64.m(+a: F64) -> U64:
  U64.shln(F64.x(a), U32.to_nat(F64.k(a)))

def F64.e(+a: F64) -> U32:
  U32.sub(U32.max(F64.field(a), 1), F64.k(a))

# 0 zero, 1 finite, 2 infinite, 3 NaN
def F64.cls(+a: F64) -> U32:
  +m = F64.mag(a)
  U32.add(Bool.to_u32(Bool.not(U64.is_zero(m))), U32.add(
    Bool.to_u32(U64.is_ge(m, F64.inf())), Bool.to_u32(U64.is_gt(m, F64.inf()))))

# a special result r (0, 2 or 3) of sign s
def F64.put(+r: U32, s: Bool) -> F64:
  F64.from_bits(Bool.pick(U64, U32.is_eq(r, 3), 0x7ff8000000000000u64,
    U64.or(U64.shln(U64.bit(s), 63n),
      Bool.pick(U64, U32.is_eq(r, 2), F64.inf(), 0u64))))

# x >> 10 rounded to nearest, ties to even
def F64.rne(+x: U64) -> U64:
  U64.and(U64.shrn(U64.add(x, 512u64), 10n), U64.not(U64.bit(
    U64.is_eq(U64.and(x, 1023u64), 512u64))))

def F64.round.at(s: Bool, +e: U32, +m: U64) -> F64:
  +neg = U32.is_ge(e, 2147483648)
  +r = U64.add(U64.shln(U64.from_u32(Bool.pick(U32, neg, 0, e)), 52n),
    F64.rne(Bool.pick(U64, neg,
      U64.shr_jam(m, U32.to_nat(U32.min(U32.sub(0, e), 64))), m)))
  F64.from_bits(U64.or(U64.shln(U64.bit(s), 63n),
    Bool.pick(U64, U64.is_ge(r, F64.inf()), F64.inf(), r)))

# m * 2^(e - 1084), 0 < m < 2^63, its top bit moved to bit 62 (the bits a
# shift moves up are exact): below 0 it goes subnormal, past 2045 infinite
def F64.round(s: Bool, e: U32, +m: U64) -> F64:
  +k = U32.sub(U64.clz(m), 1)
  F64.round.at(s, U32.sub(e, k), U64.shln(m, U32.to_nat(k)))

# the class of a product of classes t and u (also a quotient's, the
# divisor's zero and infinity swapped): NaN, 0 * inf, then the larger
def F64.lat(+t: U32, +u: U32) -> U32:
  +hi = U32.max(t, u)
  Bool.pick(U32, Bool.or(U32.is_ge(hi, 3), Bool.and(U32.is_zero(U32.min(t, u)),
    U32.is_eq(hi, 2))), 3, Bool.pick(U32, U32.is_zero(U32.min(t, u)), 0, hi))

def F64.mul.fin(s: Bool, +a: F64, +b: F64) -> F64:
  +x = U64.shln(F64.m(a), 10n)
  +y = U64.shln(F64.m(b), 11n)
  F64.round(s, U32.sub(U32.add(F64.e(a), F64.e(b)), 1023),
    U64.or(U64.mul_hi(x, y), U64.jam(U64.mul(x, y))))

# restoring division: q the quotient's bits, r the remainder, then sticky
def F64.div.go(n: Nat, +b: U64, q: U64, +r: U64) -> U64:
  match n:
    case 0n:
      U64.or(q, U64.jam(r))
    case 1n+p:
      +ge = U64.is_ge(r, b)
      F64.div.go(p, b, U64.add(U64.shl(q), U64.bit(ge)),
        U64.shl(Bool.pick(U64, ge, U64.sub(r, b), r)))

def F64.div.fin(s: Bool, +a: F64, +b: F64) -> F64:
  F64.round(s, U32.add(U32.sub(F64.e(a), F64.e(b)), 1022),
    F64.div.go(63n, F64.m(b), 0u64, F64.m(a)))

def F64.fin(op: U32, s: Bool, a: F64, b: F64) -> F64:
  match op:
    case 0:
      F64.mul.fin(s, a, b)
    case _:
      F64.div.fin(s, a, b)

# op 0 multiplies, 1 divides; r is the result's class
def F64.op(op: U32, +r: U32, s: Bool, a: F64, b: F64) -> F64:
  match r:
    case 1:
      F64.fin(op, s, a, b)
    case _:
      F64.put(r, s)

def F64.mul(+a: F64, +b: F64) -> F64:
  F64.op(0, F64.lat(F64.cls(a), F64.cls(b)),
    Bool.xor(F64.sign(a), F64.sign(b)), a, b)

def F64.div(+a: F64, +b: F64) -> F64:
  F64.op(1, F64.lat(F64.cls(a), U32.sub(2, F64.cls(b))),
    Bool.xor(F64.sign(a), F64.sign(b)), a, b)

# |a| >= |b|, both finite and nonzero: b aligned under a with a sticky
# bit (exact when they are within one bit), then added or subtracted
def F64.add.fin(+a: F64, +b: F64) -> F64:
  +x = U64.shln(F64.m(a), 9n)
  +y = U64.shr_jam(U64.shln(F64.m(b), 9n),
    U32.to_nat(U32.min(U32.sub(F64.e(a), F64.e(b)), 64)))
  +z = Bool.pick(U64, Bool.xor(F64.sign(a), F64.sign(b)), U64.sub(x, y),
    U64.add(x, y))
  Bool.pick(F64, U64.is_zero(z), F64.from_bits(0u64),
    F64.round(F64.sign(a), F64.e(a), z))

def F64.add.zero(+cb: U32, +ca: U32, +a: F64, +b: F64) -> F64:
  match cb:
    case 0:
      Bool.pick(F64, U32.is_zero(ca),
        F64.put(0, Bool.and(F64.sign(a), F64.sign(b))), a)
    case _:
      F64.add.fin(a, b)

# |a| >= |b| of classes ca and cb: a NaN is a; inf - inf is NaN; a zero b
# leaves a (-0 when both are -0)
def F64.add.big(+ca: U32, +cb: U32, +a: F64, +b: F64) -> F64:
  match ca:
    case 3:
      F64.nan()
    case 2:
      Bool.pick(F64, Bool.and(U32.is_eq(cb, 2),
        Bool.xor(F64.sign(a), F64.sign(b))), F64.nan(), a)
    case _:
      F64.add.zero(cb, ca, a, b)

def F64.add(+a: F64, +b: F64) -> F64:
  +sw = U64.is_lt(F64.mag(a), F64.mag(b))
  +x = Bool.pick(F64, sw, b, a)
  +y = Bool.pick(F64, sw, a, b)
  F64.add.big(F64.cls(x), F64.cls(y), x, y)

def F64.sub(a: F64, b: F64) -> F64:
  F64.add(a, F64.neg(b))

# a * b + c, rounded once: the product's 106 bits and the addend meet in
# one exact sum (four limbs when they overlap, the larger plus sticky
# when 107 apart they share no bit), then the one rounder
def F64.fma.o0(+w1: Bool, +s: U32, +v0: U64) -> U64:
  Bool.pick(U64, w1, 0u64, U64.shln(v0, U32.to_nat(s)))

def F64.fma.o1(+w1: Bool, +s: U32, +v0: U64, +v1: U64) -> U64:
  +n = U32.to_nat(s)
  +t = U32.to_nat(U32.sub(64, s))
  U64.or(Bool.pick(U64, w1, U64.shln(v0, n), U64.shln(v1, n)),
    Bool.pick(U64, w1, 0u64, U64.shrn(v0, t)))

def F64.fma.o2(+w1: Bool, +s: U32, +v0: U64, +v1: U64) -> U64:
  +n = U32.to_nat(s)
  +t = U32.to_nat(U32.sub(64, s))
  U64.or(Bool.pick(U64, w1, U64.shln(v1, n), 0u64),
    Bool.pick(U64, w1, U64.shrn(v0, t), U64.shrn(v1, t)))

def F64.fma.o3(+w1: Bool, +s: U32, +v1: U64) -> U64:
  Bool.pick(U64, w1, U64.shrn(v1, U32.to_nat(U32.sub(64, s))), 0u64)

# placed P (p3 down to p0) has it over placed C
def F64.fma.ge(+p3: U64, +p2: U64, +p1: U64, +p0: U64, +c3: U64, +c2: U64,
  +c1: U64, +c0: U64) -> Bool:
  Bool.or(U64.is_gt(p3, c3), Bool.and(U64.is_eq(p3, c3),
    Bool.or(U64.is_gt(p2, c2), Bool.and(U64.is_eq(p2, c2),
      Bool.or(U64.is_gt(p1, c1), Bool.and(U64.is_eq(p1, c1),
        U64.is_ge(p0, c0)))))))

# limb 0 of the signed sum: same signs add, else larger less smaller
def F64.fma.s0(+sub: Bool, +ge: Bool, +p0: U64, +c0: U64) -> U64:
  Bool.pick(U64, sub, Bool.pick(U64, ge, U64.sub(p0, c0), U64.sub(c0, p0)),
    U64.add(p0, c0))

# limb 1, carrying limb 0's carry or borrow out
def F64.fma.s1(+sub: Bool, +ge: Bool, +p1: U64, +c1: U64, +p0: U64,
  +c0: U64) -> U64:
  +k = Bool.pick(U64, sub, U64.bit(Bool.pick(Bool, ge, U64.is_lt(p0, c0),
    U64.is_lt(c0, p0))), U64.bit(U64.is_lt(U64.add(p0, c0), p0)))
  Bool.pick(U64, sub, Bool.pick(U64, ge, U64.sub(U64.sub(p1, c1), k),
    U64.sub(U64.sub(c1, p1), k)), U64.add(U64.add(p1, c1), k))

# limb 2, carrying limb 1's out (recomputed: one value leaves a def; a
# borrow leaves when the minuend is under subtrahend plus carry in)
def F64.fma.s2(+sub: Bool, +ge: Bool, +p2: U64, +c2: U64, +p1: U64, +c1: U64,
  +p0: U64, +c0: U64) -> U64:
  +k1 = Bool.pick(U64, sub, U64.bit(Bool.pick(Bool, ge, U64.is_lt(p0, c0),
    U64.is_lt(c0, p0))), U64.bit(U64.is_lt(U64.add(p0, c0), p0)))
  +s = Bool.pick(U64, sub, Bool.pick(U64, ge, U64.sub(U64.sub(p1, c1), k1),
    U64.sub(U64.sub(c1, p1), k1)), U64.add(U64.add(p1, c1), k1))
  +m = Bool.pick(U64, sub, Bool.pick(U64, ge, p1, c1), p1)
  +n = Bool.pick(U64, ge, c1, p1)
  +k2 = Bool.pick(U64, sub, U64.bit(Bool.or(U64.is_lt(m, n),
    Bool.and(U64.is_eq(k1, 1u64), U64.is_eq(m, n)))),
    U64.bit(Bool.or(U64.is_lt(s, m), Bool.and(U64.is_eq(k1, 1u64),
      U64.is_eq(s, m)))))
  Bool.pick(U64, sub, Bool.pick(U64, ge, U64.sub(U64.sub(p2, c2), k2),
    U64.sub(U64.sub(c2, p2), k2)), U64.add(U64.add(p2, c2), k2))

# limb 3, carrying limb 2's out; the sum never leaves four limbs
def F64.fma.s3(+sub: Bool, +ge: Bool, +p3: U64, +c3: U64, +p2: U64, +c2: U64,
  +p1: U64, +c1: U64, +p0: U64, +c0: U64) -> U64:
  +k1 = Bool.pick(U64, sub, U64.bit(Bool.pick(Bool, ge, U64.is_lt(p0, c0),
    U64.is_lt(c0, p0))), U64.bit(U64.is_lt(U64.add(p0, c0), p0)))
  +s1 = Bool.pick(U64, sub, Bool.pick(U64, ge, U64.sub(U64.sub(p1, c1), k1),
    U64.sub(U64.sub(c1, p1), k1)), U64.add(U64.add(p1, c1), k1))
  +m1 = Bool.pick(U64, sub, Bool.pick(U64, ge, p1, c1), p1)
  +n1 = Bool.pick(U64, ge, c1, p1)
  +k2 = Bool.pick(U64, sub, U64.bit(Bool.or(U64.is_lt(m1, n1),
    Bool.and(U64.is_eq(k1, 1u64), U64.is_eq(m1, n1)))),
    U64.bit(Bool.or(U64.is_lt(s1, m1), Bool.and(U64.is_eq(k1, 1u64),
      U64.is_eq(s1, m1)))))
  +s2 = Bool.pick(U64, sub, Bool.pick(U64, ge, U64.sub(U64.sub(p2, c2), k2),
    U64.sub(U64.sub(c2, p2), k2)), U64.add(U64.add(p2, c2), k2))
  +m2 = Bool.pick(U64, sub, Bool.pick(U64, ge, p2, c2), p2)
  +n2 = Bool.pick(U64, ge, c2, p2)
  +k3 = Bool.pick(U64, sub, U64.bit(Bool.or(U64.is_lt(m2, n2),
    Bool.and(U64.is_eq(k2, 1u64), U64.is_eq(m2, n2)))),
    U64.bit(Bool.or(U64.is_lt(s2, m2), Bool.and(U64.is_eq(k2, 1u64),
      U64.is_eq(s2, m2)))))
  Bool.pick(U64, sub, Bool.pick(U64, ge, U64.sub(U64.sub(p3, c3), k3),
    U64.sub(U64.sub(c3, p3), k3)), U64.add(U64.add(p3, c3), k3))

# a zero sum is +0; else the sum normalized to the top, its top 63 bits
# and whether anything fell below them to the one rounder
def F64.fma.norm(+s: Bool, +e0: U32, +a3: U64, +a2: U64, +a1: U64,
  +a0: U64) -> F64:
  +z = Bool.and(U64.is_zero(a3), Bool.and(U64.is_zero(a2),
    Bool.and(U64.is_zero(a1), U64.is_zero(a0))))
  +lz = Bool.pick(U32, U64.is_zero(a3), Bool.pick(U32, U64.is_zero(a2),
    Bool.pick(U32, U64.is_zero(a1), U32.add(192, U64.clz(a0)),
      U32.add(128, U64.clz(a1))), U32.add(64, U64.clz(a2))), U64.clz(a3))
  F64.fma.at(s, e0, lz, z, a3, a2, a1, a0)

def F64.fma.at(+s: Bool, +e0: U32, +lz: U32, +z: Bool, +a3: U64, +a2: U64,
  +a1: U64, +a0: U64) -> F64:
  match z:
    case True{}:
      F64.put(0, False{})
    case False{}:
      F64.fma.up(s, e0, lz, a3, a2, a1, a0)

# the sum up by lz (its top now bit 255), rounded from its top 63 bits
# with the rest as sticky, at e0 - 1075 + 255 - lz - 62 + 1084
def F64.fma.up(+s: Bool, +e0: U32, +lz: U32, +a3: U64, +a2: U64, +a1: U64,
  +a0: U64) -> F64:
  +w = U32.shrn(lz, 6n)
  +n = U32.to_nat(U32.and(lz, 63))
  +t = U32.to_nat(U32.sub(64, U32.and(lz, 63)))
  +b3 = F64.fma.sh(w, n, t, a3, a2, a1, a0)
  +b2 = F64.fma.sh(w, n, t, a2, a1, a0, 0u64)
  +b1 = F64.fma.sh(w, n, t, a1, a0, 0u64, 0u64)
  +b0 = F64.fma.sh(w, n, t, a0, 0u64, 0u64, 0u64)
  +st = Bool.or(Bool.or(U64.is_eq(U64.and(b3, 1u64), 1u64),
    Bool.not(U64.is_zero(b2))), Bool.or(Bool.not(U64.is_zero(b1)),
    Bool.not(U64.is_zero(b0))))
  F64.round(s, U32.sub(U32.add(e0, 202), lz),
    U64.or(U64.shrn(b3, 1n), U64.bit(st)))

# limb i of the sum up by whole words w and n bits (t its complement)
def F64.fma.sh(+w: U32, +n: Nat, +t: Nat, +v0: U64, +v1: U64, +v2: U64,
  +v3: U64) -> U64:
  +x0 = U64.or(U64.shln(v0, n), U64.shrn(v1, t))
  +x1 = U64.or(U64.shln(v1, n), U64.shrn(v2, t))
  +x2 = U64.or(U64.shln(v2, n), U64.shrn(v3, t))
  +x3 = U64.shln(v3, n)
  Bool.pick(U64, U32.is_eq(w, 0), x0, Bool.pick(U64, U32.is_eq(w, 1), x1,
    Bool.pick(U64, U32.is_eq(w, 2), x2, x3)))

# |d| under 107: P and C placed at their offsets in four limbs, combined
# by sign from limb 0's base exponent
def F64.fma.wide(+sp: Bool, +sc: Bool, +neg: Bool, +ad: U32, +ma: U64,
  +mb: U64, +mc: U64, +bp: U32, +ec: U32) -> F64:
  +wp = Bool.pick(Bool, neg, U32.is_ge(ad, 64), False{})
  +wc = Bool.pick(Bool, neg, False{}, U32.is_ge(ad, 64))
  +s = U32.and(ad, 63)
  +ph = U64.mul_hi(ma, mb)
  +pl = U64.mul(ma, mb)
  +p3 = F64.fma.o3(wp, Bool.pick(U32, neg, s, 0), ph)
  +p2 = F64.fma.o2(wp, Bool.pick(U32, neg, s, 0), pl, ph)
  +p1 = F64.fma.o1(wp, Bool.pick(U32, neg, s, 0), pl, ph)
  +p0 = F64.fma.o0(wp, Bool.pick(U32, neg, s, 0), pl)
  +c3 = F64.fma.o3(wc, Bool.pick(U32, neg, 0, s), 0u64)
  +c2 = F64.fma.o2(wc, Bool.pick(U32, neg, 0, s), mc, 0u64)
  +c1 = F64.fma.o1(wc, Bool.pick(U32, neg, 0, s), mc, 0u64)
  +c0 = F64.fma.o0(wc, Bool.pick(U32, neg, 0, s), mc)
  +sub = Bool.xor(sp, sc)
  +ge = F64.fma.ge(p3, p2, p1, p0, c3, c2, c1, c0)
  +a0 = F64.fma.s0(sub, ge, p0, c0)
  +a1 = F64.fma.s1(sub, ge, p1, c1, p0, c0)
  +a2 = F64.fma.s2(sub, ge, p2, c2, p1, c1, p0, c0)
  +a3 = F64.fma.s3(sub, ge, p3, c3, p2, c2, p1, c1, p0, c0)
  F64.fma.norm(Bool.pick(Bool, sub, Bool.pick(Bool, ge, sp, sc), sp),
    Bool.pick(U32, neg, ec, bp), a3, a2, a1, a0)

# |d| at 107: the operands share no bit, so the larger keeps its bits and
# the smaller (nonzero) is only sticky, taken as the low bit to round
def F64.fma.far(+sp: Bool, +sc: Bool, +neg: Bool, +ma: U64, +mb: U64,
  +mc: U64, +bp: U32, +ec: U32) -> F64:
  match neg:
    case True{}:
      +r64 = U64.or(U64.shln(U64.mul_hi(ma, mb), 22n),
        U64.shrn(U64.mul(ma, mb), 42n))
      F64.round(sp, U32.add(bp, 52), U64.or(U64.shrn(r64, 1n), 1u64))
    case False{}:
      F64.round(sc, U32.sub(ec, 1), U64.or(U64.shln(mc, 10n), 1u64))

# an infinite product of sign sp meets c of class cc and sign sc
def F64.fma.p_inf(+cc: U32, +sp: Bool, +sc: Bool) -> F64:
  Bool.pick(F64, Bool.and(U32.is_eq(cc, 2), Bool.xor(sp, sc)), F64.nan(),
    F64.put(2, sp))

# the exact sum of product and c, both finite and nonzero: d the addend's
# height over the product (modular, as the rounder reads it), far or wide
def F64.fma.sum(+sp: Bool, +sc: Bool, +a: F64, +b: F64, +c: F64) -> F64:
  +bp = U32.sub(U32.add(F64.e(a), F64.e(b)), 1075)
  +dm = U32.sub(F64.e(c), bp)
  +neg = U32.is_ge(dm, 2147483648)
  +ad = Bool.pick(U32, neg, U32.sub(0, dm), dm)
  +ma = F64.m(a)
  +mb = F64.m(b)
  +mc = F64.m(c)
  +ec = F64.e(c)
  F64.fma.which(U32.is_ge(ad, 107), sp, sc, neg, ad, ma, mb, mc, bp, ec)

def F64.fma.which(+g: Bool, +sp: Bool, +sc: Bool, +neg: Bool, +ad: U32,
  +ma: U64, +mb: U64, +mc: U64, +bp: U32, +ec: U32) -> F64:
  match g:
    case True{}:
      F64.fma.far(sp, sc, neg, ma, mb, mc, bp, ec)
    case False{}:
      F64.fma.wide(sp, sc, neg, ad, ma, mb, mc, bp, ec)

# classes ca cb cc, product sign sp: one tag (NaN or 0 * inf, a zero
# product, an infinite product, else c's class past 3), one match
def F64.fma.ab(+ca: U32, +cb: U32, +cc: U32, +sp: Bool, +sc: Bool, +a: F64,
  +b: F64, +c: F64) -> F64:
  +nan = Bool.or(U32.is_eq(ca, 3), Bool.or(U32.is_eq(cb, 3),
    U32.is_eq(cc, 3)))
  +zi = Bool.or(Bool.and(U32.is_zero(ca), U32.is_eq(cb, 2)),
    Bool.and(U32.is_eq(ca, 2), U32.is_zero(cb)))
  +zp = Bool.or(U32.is_zero(ca), U32.is_zero(cb))
  +ip = Bool.or(U32.is_eq(ca, 2), U32.is_eq(cb, 2))
  +t = Bool.pick(U32, Bool.or(nan, zi), 0, Bool.pick(U32, zp, 1,
    Bool.pick(U32, ip, 2, U32.add(3, cc))))
  F64.fma.arm(t, cc, sp, sc, a, b, c)

def F64.fma.arm(+t: U32, +cc: U32, +sp: Bool, +sc: Bool, +a: F64, +b: F64,
  +c: F64) -> F64:
  match t:
    case 0:
      F64.nan()
    case 1:
      F64.add(F64.put(0, sp), c)
    case 2:
      F64.fma.p_inf(cc, sp, sc)
    case 3:
      F64.mul.fin(sp, a, b)
    case 4:
      F64.fma.sum(sp, sc, a, b, c)
    case _:
      F64.put(2, sc)

def F64.fma(+a: F64, +b: F64, +c: F64) -> F64:
  F64.fma.ab(F64.cls(a), F64.cls(b), F64.cls(c),
    Bool.xor(F64.sign(a), F64.sign(b)), F64.sign(c), a, b, c)

# digit by digit: each step brings the next two bits of m into r, 4r + p,
# and keeps a root bit when 4q + 1 fits; 55 bits, then sticky
def F64.sqrt.go(n: Nat, +m: U64, +q: U64, +r: U64) -> U64:
  match n:
    case 0n:
      U64.or(U64.shln(q, 8n), U64.jam(r))
    case 1n+p:
      +t = U64.or(U64.shln(r, 2n), U64.shrn(m, 52n))
      +c = U64.or(U64.shln(q, 2n), 1u64)
      +ge = U64.is_ge(t, c)
      F64.sqrt.go(p, U64.and(U64.shln(m, 2n), 0x003fffffffffffffu64),
        U64.or(U64.shl(q), U64.bit(ge)), Bool.pick(U64, ge, U64.sub(t, c), t))

# an even exponent (m doubled when odd) halves exactly
def F64.sqrt.fin(+a: F64) -> F64:
  +e = F64.e(a)
  +odd = U32.xor(U32.and(e, 1), 1)
  F64.round(False{}, U32.add(U32.shrn(U32.sub(U32.add(e, 973), odd), 1n), 24),
    F64.sqrt.go(55n, U64.shln(F64.m(a), U32.to_nat(odd)), 0u64,
      0u64))

def F64.sqrt.at(+c: U32, a: F64) -> F64:
  match c:
    case 1:
      F64.sqrt.fin(a)
    case 3:
      F64.nan()
    case _:
      a

# a NaN or a negative nonzero is NaN; a zero or +inf is itself
def F64.sqrt(+a: F64) -> F64:
  +c = F64.cls(a)
  F64.sqrt.at(Bool.pick(U32, Bool.and(F64.sign(a), U32.is_ne(c, 0)), 3, c), a)

# the order as unsigned: negatives flipped, both zeros one key
def F64.key(+a: F64) -> U64:
  +b = F64.bits(a)
  Bool.pick(U64, F64.is_zero(a), 0x8000000000000000u64, Bool.pick(U64,
    F64.sign(a), U64.not(b), U64.or(b, 0x8000000000000000u64)))

def F64.ord(+a: F64, +b: F64) -> Bool:
  Bool.not(Bool.or(F64.is_nan(a), F64.is_nan(b)))

def F64.is_eq(+a: F64, +b: F64) -> Bool:
  Bool.and(F64.ord(a, b), U64.is_eq(F64.key(a), F64.key(b)))

def F64.is_ne(a: F64, b: F64) -> Bool:
  Bool.not(F64.is_eq(a, b))

def F64.is_lt(+a: F64, +b: F64) -> Bool:
  Bool.and(F64.ord(a, b), U64.is_lt(F64.key(a), F64.key(b)))

def F64.is_le(+a: F64, +b: F64) -> Bool:
  Bool.and(F64.ord(a, b), U64.is_le(F64.key(a), F64.key(b)))

def F64.is_gt(a: F64, b: F64) -> Bool:
  F64.is_lt(b, a)

def F64.is_ge(a: F64, b: F64) -> Bool:
  F64.is_le(b, a)

def U64.to_f64(+u: U64) -> F64:
  +t = U64.is_ge(u, 0x8000000000000000u64)
  Bool.pick(F64, U64.is_zero(u), F64.from_bits(u), F64.round(False{},
    U32.add(1084, Bool.to_u32(t)), U64.shr_jam(u, U32.to_nat(Bool.to_u32(t)))))

# toward zero, out of range (NaN, infinite, negative, past 2^32) to 0;
# in range the exponent sits under 1075, so one shift down truncates (a
# denormal's wrapped exponent shifts everything out)
def F64.to_u32(+a: F64) -> U32:
  +m = F64.mag(a)
  Bool.pick(U32, Bool.or(F64.sign(a), U64.is_ge(m, 0x41F0000000000000u64)), 0,
    U64.lo(U64.shrn(F64.m(a), U32.to_nat(U32.sub(1075, F64.e(a))))))

# toward zero, out of range (NaN, infinite, negative, past 2^64) to 0
def F64.to_u64(+a: F64) -> U64:
  +m = F64.mag(a)
  +e = F64.e(a)
  Bool.pick(U64, Bool.or(F64.sign(a), U64.is_ge(m, 0x43F0000000000000u64)),
    0u64, Bool.pick(U64, U32.is_ge(e, 1075),
      U64.shln(F64.m(a), U32.to_nat(U32.sub(e, 1075))),
      U64.shrn(F64.m(a), U32.to_nat(U32.sub(1075, e)))))

# the nearest f32, ties to even; a NaN canonical, the rest at their class
def F64.to_f32.at(+c: U32, +s: Bool, +a: F64) -> F32:
  match c:
    case 3:
      F32.from_bits(0x7FC00000)
    case 2:
      F32.from_bits(U32.or(U32.shln(Bool.to_u32(s), 31n), 0x7F800000))
    case 0:
      F32.from_bits(U32.shln(Bool.to_u32(s), 31n))
    case _:
      F64.to_f32.fin(s, F64.m(a), F64.e(a))

# the 53-bit significand rounded to 24, ties to even (a carry
# renormalizes), packed at its f32 exponent e - 896 plus the carry
def F64.to_f32.fin(+s: Bool, +m: U64, +e: U32) -> F32:
  +q = U64.shrn(m, 29n)
  +rem = U64.and(m, 0x1FFFFFFFu64)
  +rb = U64.is_ne(U64.and(rem, 0x10000000u64), 0u64)
  +st = U64.is_ne(U64.and(rem, 0xFFFFFFFu64), 0u64)
  +odd = U64.is_ne(U64.and(q, 1u64), 0u64)
  +r = U64.add(q, U64.bit(Bool.and(rb, Bool.or(st, odd))))
  +cy = U64.is_ge(r, 0x1000000u64)
  +q24 = Bool.pick(U64, cy, U64.shrn(r, 1n), r)
  F64.to_f32.pk(s, U32.add(U32.sub(e, 896), Bool.to_u32(cy)), q24)

# packed at be (modular, as the rounder reads it): subnormal, infinite,
# or the sign, exponent and 23 fraction bits
def F64.to_f32.pk(+s: Bool, +be: U32, +q24: U64) -> F32:
  +neg = U32.is_ge(be, 2147483648)
  +ov = U32.is_ge(be, 255)
  Bool.pick(F32, Bool.or(neg, U32.is_zero(be)), F64.to_f32.sub(s, be, q24),
    Bool.pick(F32, ov, F32.from_bits(U32.or(U32.shln(Bool.to_u32(s), 31n),
      0x7F800000)), F32.from_bits(U32.or(U32.or(U32.shln(Bool.to_u32(s), 31n),
      U32.shln(be, 23n)), U64.lo(U64.and(q24, 0x7FFFFFu64))))))

# a subnormal: q24 down by 1 - be with its own round bit and sticky (a
# carry out is the smallest normal)
def F64.to_f32.sub(+s: Bool, +be: U32, +q24: U64) -> F32:
  +sh = U32.sub(1, be)
  +shn = U32.to_nat(sh)
  +g = U64.and(U64.shrn(q24, U32.to_nat(U32.sub(sh, 1))), 1u64)
  +rs = U64.is_ne(U64.and(q24, U64.sub(U64.shln(1u64,
    U32.to_nat(U32.sub(sh, 1))), 1u64)), 0u64)
  +e0 = U64.and(U64.shrn(q24, shn), 1u64)
  +sig = U64.add(U64.shrn(q24, shn), U64.bit(Bool.and(U64.is_ne(g, 0u64),
    Bool.or(rs, U64.is_ne(e0, 0u64)))))
  Bool.pick(F32, U64.is_ge(sig, 0x800000u64),
    F32.from_bits(U32.or(U32.shln(Bool.to_u32(s), 31n), 0x800000)),
    F32.from_bits(U32.or(U32.shln(Bool.to_u32(s), 31n), U64.lo(sig))))

def F64.to_f32(+a: F64) -> F32:
  F64.to_f32.at(F64.cls(a), F64.sign(a), a)

law F64.show:
  for +a: F64
  String

law F64.read:
  for s: String
  Maybe<&2, F64>
