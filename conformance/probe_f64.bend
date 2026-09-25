import Base

type BF is Data:
  BF{a: U32, b: F64, c: Bool}

def vals() -> List<U64>:
  [0u64, 9223372036854775808u64, 1u64,
   4503599627370495u64, 4503599627370496u64, 4607182418800017408u64,
   4591870180066957722u64, 9218868437227405311u64, 9218868437227405312u64,
   18442240474082181120u64, 9221120237041090560u64, 9221120237041090851u64,
   9218868437227405313u64, 18443366373989023744u64, 18446744073709551615u64,
   4895412794951729152u64, 4895412794951729151u64, 13835058055282163712u64,
   4845873199050653697u64, 4751297606873776128u64]

def f_id(x: F64) -> F64:
  x

def f_mk(x: F64) -> BF:
  BF{7, x, True{}}

def f_un(v: BF) -> F64:
  match v:
    case BF{a, b, c}:
      b

def sndf(r: Array<F64> & F64) -> F64:
  (a2, v) = r
  v

def mkf(x: F64) -> U64 -> F64:
  y => F64{U64.xor(y, F64.bits(x))}

def cmp6(+a: F64, +b: F64) -> U64:
  U64.or(U64.or(U64.or(Bool.to_u64(F64.is_eq(a, b)), U64.shln(Bool.to_u64(F64.is_ne(a, b)), 1n)),
    U64.or(U64.shln(Bool.to_u64(F64.is_lt(a, b)), 2n), U64.shln(Bool.to_u64(F64.is_le(a, b)), 3n))),
    U64.or(U64.shln(Bool.to_u64(F64.is_gt(a, b)), 4n), U64.shln(Bool.to_u64(F64.is_ge(a, b)), 5n)))

def op(k: Nat, +x: F64) -> U64:
  match k:
    case 0n:
      F64.bits(f_id(x))
    case 1n:
      F64.bits(f_un(f_mk(x)))
    case 2n:
      F64.bits(Pair.snd(U32, F64, (5, x)))
    case 3n:
      F64.bits(Maybe.default(&2, F64, Some{x}, 0.0f64))
    case 4n:
      F64.bits(sndf(Array.get(F64, Array.set(F64, [0.0f64 : F64*4n], 2, x), 2)))
    case 5n:
      F64.bits(mkf(x)(0u64))
    case 6n:
      F64.bits(Bool.pick(F64, True{}, x, 0.0f64))
    case 7n:
      F64.bits(f_id!(x))
    case 8n:
      F64.bits(F64.neg(x))
    case 9n:
      F64.bits(F64.abs(x))
    case 10n:
      F64.bits(F64.add(x, 1.0f64))
    case 11n:
      F64.bits(F64.mul(x, x))
    case 12n:
      F64.bits(F64.div(x, 3.0f64))
    case 13n:
      F64.bits(F64.sqrt(x))
    case 14n:
      F64.bits(F64.sub(x, x))
    case 15n:
      cmp6(x, x)
    case 16n:
      cmp6(x, 1.0f64)
    case 17n:
      cmp6(x, F64{9223372036854775808u64})
    case 18n:
      F64.to_u64(x)
    case 19n:
      U32.to_u64(F64.to_u32(x))
    case 20n:
      U32.to_u64(F32.bits(F64.to_f32(x)))
    case _:
      F64.bits(U64.to_f64(F64.to_u64(x)))

law each:
  for +k: Nat
  for xs: List<U64>
  String

def each(k, xs):
  match xs:
    case Nil{}:
      "|"
    case Con{h, t}:
      U64.show(op(k, F64{h})) ++ " " ++ each(k, t)

law shows:
  for xs: List<U64>
  String

def shows(xs):
  match xs:
    case Nil{}:
      "|"
    case Con{h, t}:
      F64.show(F64{h}) ++ " " ++ shows(t)

law all:
  for +n: Nat
  String

def all(n):
  match n:
    case 0n:
      each(0n, vals())
    case 1n+p:
      all(p) ++ " " ++ each(1n+p, vals())

def main() -> String:
  all(21n) ++ " " ++ shows(vals())
