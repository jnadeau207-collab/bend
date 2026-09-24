# F64's conversions, bit-exact against truncation and round-to-nearest:
# toward-zero to U32 and U64 (NaN, infinite, negative and out-of-range
# to 0; the 2^32 and 2^64 edges) and to F32 (ties to even, overflow to
# infinity, the subnormal edges, a NaN canonical). The interpreter runs
# Base's software core; C and JS run their natives, the device lanes the
# core; each count is of the vectors kept, per op.
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
    case _:
      0

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
    case _:
      1048576

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
    case _:
      0

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

def main() -> IO(Unit):
  IO.print(U32.show(kept0(21n)) ++ " " ++ U32.show(kept1(21n))
    ++ " " ++ U32.show(kept2(21n)))

#|21 21 21
