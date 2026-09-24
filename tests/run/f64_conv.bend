# F64's conversions, bit-exact against truncation and round-to-nearest:
# toward-zero to U32 and U64 (NaN, infinite, negative and out-of-range
# to 0; the 2^32 and 2^64 edges) and to F32 (ties to even, overflow to
# infinity, the subnormal edges with round-ups, a NaN canonical). The
# first three counts call the top defs (natives on a double lane, the
# core on a spin lane); the fourth calls the core's at directly, so it
# guards the core on every lane.
import Base

def alo(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      0
    case 2:
      0
    case 3:
      0
    case 4:
      2576980378
    case 5:
      4294967295
    case 6:
      0
    case 7:
      4294967295
    case 8:
      0
    case 9:
      0
    case 10:
      0
    case 11:
      1
    case 12:
      1
    case 13:
      0
    case 14:
      1
    case 15:
      4294967295
    case 16:
      0
    case 17:
      0
    case 18:
      0
    case 19:
      0
    case 20:
      0
    case 21:
      1610612736
    case 22:
      3758096384
    case 23:
      1610612735
    case 24:
      536870913
    case 25:
      4294967295
    case 26:
      4294967295
    case 27:
      0
    case 28:
      1
    case 29:
      4294967295
    case 30:
      1610612736
    case _:
      2684354560

def ahi(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      2147483648
    case 2:
      1072693248
    case 3:
      1074266112
    case 4:
      1069128089
    case 5:
      1106247679
    case 6:
      1106247680
    case 7:
      1139802111
    case 8:
      1139802112
    case 9:
      2146435072
    case 10:
      4293918720
    case 11:
      2146959360
    case 12:
      0
    case 13:
      3220176896
    case 14:
      1072693248
    case 15:
      2146435071
    case 16:
      939524096
    case 17:
      916455424
    case 18:
      1056964608
    case 19:
      1048576000
    case 20:
      1048576
    case 21:
      939524096
    case 22:
      939524096
    case 23:
      939524096
    case 24:
      939524096
    case 25:
      916455423
    case 26:
      1072693247
    case 27:
      915406848
    case 28:
      915406848
    case 29:
      1206910975
    case 30:
      3087007744
    case _:
      937426944

def rlo0(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      0
    case 2:
      1
    case 3:
      3
    case 4:
      0
    case 5:
      4294967295
    case 6:
      0
    case 7:
      0
    case 8:
      0
    case 9:
      0
    case 10:
      0
    case 11:
      0
    case 12:
      0
    case 13:
      0
    case 14:
      1
    case 15:
      0
    case 16:
      0
    case 17:
      0
    case 18:
      0
    case 19:
      0
    case 20:
      0
    case 21:
      0
    case 22:
      0
    case _:
      0

def rlo1(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      0
    case 2:
      1
    case 3:
      3
    case 4:
      0
    case 5:
      4294967295
    case 6:
      0
    case 7:
      4294965248
    case 8:
      0
    case 9:
      0
    case 10:
      0
    case 11:
      0
    case 12:
      0
    case 13:
      0
    case 14:
      1
    case 15:
      0
    case 16:
      0
    case 17:
      0
    case 18:
      0
    case 19:
      0
    case 20:
      0
    case 21:
      0
    case 22:
      0
    case _:
      0

def rhi1(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      0
    case 2:
      0
    case 3:
      0
    case 4:
      0
    case 5:
      0
    case 6:
      1
    case 7:
      4294967295
    case 8:
      0
    case 9:
      0
    case 10:
      0
    case 11:
      0
    case 12:
      0
    case 13:
      0
    case 14:
      0
    case 15:
      0
    case 16:
      0
    case 17:
      0
    case 18:
      0
    case 19:
      0
    case 20:
      0
    case 21:
      0
    case 22:
      0
    case _:
      0

def rlo2(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      2147483648
    case 2:
      1065353216
    case 3:
      1077936128
    case 4:
      1036831949
    case 5:
      1333788672
    case 6:
      1333788672
    case 7:
      1602224128
    case 8:
      1602224128
    case 9:
      2139095040
    case 10:
      4286578688
    case 11:
      2143289344
    case 12:
      0
    case 13:
      3212836864
    case 14:
      1065353216
    case 15:
      2139095040
    case 16:
      4194304
    case 17:
      1
    case 18:
      939524096
    case 19:
      872415232
    case 20:
      0
    case 21:
      4194306
    case 22:
      4194308
    case 23:
      4194305
    case 24:
      4194305
    case 25:
      1
    case 26:
      1065353216
    case 27:
      0
    case 28:
      1
    case 29:
      2139095040
    case 30:
      2151677954
    case _:
      1048577

def fa(+i: U32) -> F64:
  F64.from_bits(U64.join(alo(i), ahi(i)))

def ok0(+i: U32) -> U32:
  Bool.to_u32(U32.is_eq(F64.to_u32(fa(i)), rlo0(i)))

def kept0(+n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      U32.add(kept0(p), ok0(U32.from_nat(p)))

def ok1(+i: U32) -> U32:
  +r = F64.to_u64(fa(i))
  Bool.to_u32(Bool.and(U32.is_eq(U64.lo(r), rlo1(i)),
    U32.is_eq(U64.hi(r), rhi1(i))))

def kept1(+n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      U32.add(kept1(p), ok1(U32.from_nat(p)))

def ok2(+i: U32) -> U32:
  Bool.to_u32(U32.is_eq(F32.bits(F64.to_f32(fa(i))), rlo2(i)))

def kept2(+n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      U32.add(kept2(p), ok2(U32.from_nat(p)))

def ok3(+i: U32) -> U32:
  +a = fa(i)
  Bool.to_u32(U32.is_eq(F32.bits(F64.to_f32.at(F64.cls(a), F64.sign(a), a)),
    rlo2(i)))

def kept3(+n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      U32.add(kept3(p), ok3(U32.from_nat(p)))

def main() -> IO(Unit):
  IO.print(U32.show(kept0(32n)) ++ " " ++ U32.show(kept1(32n))
    ++ " " ++ U32.show(kept2(32n)) ++ " " ++ U32.show(kept3(32n)))

#|32 32 32 32
