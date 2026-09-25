import Base

type B64 is Data:
  B64{a: U32, b: U64, c: Bool}

def vals() -> List<U64>:
  [0u64, 1u64, 4294967296u64, 281474976710656u64, 9007199254740991u64,
   9007199254740992u64, 9007199254740993u64, 9223372036854775808u64,
   18446744073709551615u64, 72057594037927937u64, 144115188075856163u64,
   360287970189639680u64, 9151595913498591232u64, 9223372036854775809u64,
   18374686483966590975u64]

def p_id(x: U64) -> U64:
  x

def p_mkbox(x: U64) -> B64:
  B64{7, x, True{}}

def p_unbox(v: B64) -> U64:
  match v:
    case B64{a, b, c}:
      b

law p_rec:
  for n: Nat
  for x: U64
  U64

def p_rec(n, x):
  match n:
    case 0n:
      x
    case 1n+p:
      U64.xor(p_rec(p, x), 0u64)

def p_fork(+x: U64) -> U64:
  a b = p_id(x) p_id(U64.not(x))
  U64.xor(a, U64.xor(U64.not(b), x))

def snd64(r: Array<U64> & U64) -> U64:
  (a2, v) = r
  v

def mk(x: U64) -> U64 -> U64:
  y => U64.xor(y, x)

def apply(k: Nat, x: U64) -> U64:
  match k:
    case 0n:
      p_id(x)
    case 1n:
      p_unbox(p_mkbox(x))
    case 2n:
      Pair.snd(U32, U64, (5, x))
    case 3n:
      Pair.fst(U64, U32, (x, 9))
    case 4n:
      Maybe.default(&2, U64, Some{x}, 0u64)
    case 5n:
      p_rec(40n, x)
    case 6n:
      p_fork(x)
    case 7n:
      snd64(Array.get(U64, Array.set(U64, [0u64 : U64*4n], 2, x), 2))
    case 8n:
      snd64(Array.swap(U64, Array.set(U64, [0u64 : U64*2n], 1, x), 1, 3u64))
    case 9n:
      mk(x)(0u64)
    case 10n:
      Bool.pick(U64, True{}, x, 0u64)
    case _:
      p_id!(x)

law each:
  for +k: Nat
  for xs: List<U64>
  String

def each(k, xs):
  match xs:
    case Nil{}:
      "|"
    case Con{h, t}:
      U64.show(apply(k, h)) ++ " " ++ each(k, t)

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
  all(11n)
