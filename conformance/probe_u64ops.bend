import Base

def vals() -> List<U64>:
  [0u64, 1u64, 4294967295u64, 4294967296u64, 9223372036854775808u64,
   18446744073709551615u64, 12345678901234567890u64]

def bin(k: Nat, +a: U64, +b: U64) -> U64:
  match k:
    case 0n:
      U64.add(a, b)
    case 1n:
      U64.sub(a, b)
    case 2n:
      U64.mul(a, b)
    case 3n:
      U64.mul_hi(a, b)
    case 4n:
      U64.div(a, b)
    case 5n:
      U64.mod(a, b)
    case 6n:
      U64.and(a, b)
    case 7n:
      U64.or(a, b)
    case 8n:
      U64.xor(a, b)
    case 9n:
      Bool.to_u64(U64.is_lt(a, b))
    case 10n:
      Bool.to_u64(U64.is_eq(a, b))
    case 11n:
      U64.shln(a, U64.to_nat(U64.and(b, 127u64)))
    case 12n:
      U64.shrn(a, U64.to_nat(U64.and(b, 127u64)))
    case 13n:
      U64.min(a, b)
    case _:
      U64.max(a, b)

def un(k: Nat, +a: U64) -> U64:
  match k:
    case 0n:
      U32.to_u64(U64.clz(a))
    case 1n:
      U64.not(a)
    case 2n:
      U64.shl(a)
    case 3n:
      U64.shr(a)
    case 4n:
      U64.inc(a)
    case 5n:
      U32.to_u64(U64.to_u32(a))
    case 6n:
      F64.bits(U64.to_f64(a))
    case _:
      Bool.to_u64(U64.is_zero(a))

law row:
  for +k: Nat
  for +a: U64
  for bs: List<U64>
  String

def row(k, a, bs):
  match bs:
    case Nil{}:
      ""
    case Con{b, t}:
      U64.show(bin(k, a, b)) ++ " " ++ row(k, a, t)

law rows:
  for +k: Nat
  for xs: List<U64>
  String

def rows(k, xs):
  match xs:
    case Nil{}:
      "|"
    case Con{a, t}:
      row(k, a, vals()) ++ rows(k, t)

law unary:
  for +k: Nat
  for xs: List<U64>
  String

def unary(k, xs):
  match xs:
    case Nil{}:
      "|"
    case Con{a, t}:
      U64.show(un(k, a)) ++ " " ++ unary(k, t)

law allb:
  for +n: Nat
  String

def allb(n):
  match n:
    case 0n:
      rows(0n, vals())
    case 1n+p:
      allb(p) ++ " " ++ rows(1n+p, vals())

law allu:
  for +n: Nat
  String

def allu(n):
  match n:
    case 0n:
      unary(0n, vals())
    case 1n+p:
      allu(p) ++ " " ++ unary(1n+p, vals())

def main() -> String:
  allb(14n) ++ " " ++ allu(7n)
