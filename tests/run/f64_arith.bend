# F64's add, sub, mul, div and sqrt, bit-exact against the host's IEEE
# doubles (a NaN the canonical 0x7ff8000000000000): inf - inf, 0 * inf,
# 0 / 0, x / 0, the signed-zero sums, a signaling NaN and a payload NaN,
# exact ties (1 + 2^-53, a 54-bit product, halving 1 and 3 ulps), the
# subnormal edge both ways, overflow at the largest finite, a cancellation
# to one ulp, 1/3, sqrt of 2, of -4 and of a subnormal. The interpreter
# runs Base's software core, which C and JS compile too; each count is of
# the vectors kept, per op.
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
      0
    case 5:
      0
    case 6:
      0
    case 7:
      1
    case 8:
      0
    case 9:
      0
    case 10:
      4294967295
    case 11:
      0
    case 12:
      4294967295
    case 13:
      1
    case 14:
      3
    case 15:
      4294967295
    case 16:
      4294967295
    case 17:
      0
    case 18:
      0
    case 19:
      1
    case 20:
      0
    case 21:
      0
    case 22:
      0
    case 23:
      0
    case 24:
      2
    case 25:
      0
    case _:
      0

def ahi(n: U32) -> U32:
  match n:
    case 0:
      2146435072
    case 1:
      0
    case 2:
      0
    case 3:
      1072693248
    case 4:
      2147483648
    case 5:
      0
    case 6:
      2147483648
    case 7:
      2146435072
    case 8:
      3220176896
    case 9:
      1073217536
    case 10:
      1073741823
    case 11:
      1048576
    case 12:
      1048575
    case 13:
      0
    case 14:
      0
    case 15:
      2146435071
    case 16:
      2146435071
    case 17:
      1072693248
    case 18:
      1072693248
    case 19:
      1072693248
    case 20:
      1128267776
    case 21:
      1072693248
    case 22:
      1073741824
    case 23:
      3222274048
    case 24:
      0
    case 25:
      2145386496
    case _:
      524288

def blo(n: U32) -> U32:
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
      0
    case 7:
      0
    case 8:
      291
    case 9:
      67108864
    case 10:
      4294967295
    case 11:
      0
    case 12:
      1
    case 13:
      0
    case 14:
      0
    case 15:
      1
    case 16:
      4294967295
    case 17:
      0
    case 18:
      1
    case 19:
      0
    case 20:
      0
    case 21:
      0
    case 22:
      0
    case 23:
      0
    case 24:
      0
    case 25:
      3
    case _:
      0

def bhi(n: U32) -> U32:
  match n:
    case 0:
      4293918720
    case 1:
      2146435072
    case 2:
      0
    case 3:
      0
    case 4:
      2147483648
    case 5:
      2147483648
    case 6:
      0
    case 7:
      1072693248
    case 8:
      2146959360
    case 9:
      1073217536
    case 10:
      1073741823
    case 11:
      1071644672
    case 12:
      0
    case 13:
      1071644672
    case 14:
      1071644672
    case 15:
      1072693248
    case 16:
      2090860543
    case 17:
      1017118720
    case 18:
      1017118720
    case 19:
      3220176896
    case 20:
      3220176896
    case 21:
      1074266112
    case 22:
      0
    case 23:
      1072693248
    case 24:
      2145386496
    case 25:
      0
    case _:
      1072693248

def rlo0(n: U32) -> U32:
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
      0
    case 7:
      0
    case 8:
      0
    case 9:
      33554432
    case 10:
      4294967295
    case 11:
      0
    case 12:
      0
    case 13:
      0
    case 14:
      0
    case 15:
      4294967295
    case 16:
      0
    case 17:
      0
    case 18:
      1
    case 19:
      0
    case 20:
      4294967295
    case 21:
      0
    case 22:
      0
    case 23:
      0
    case 24:
      0
    case 25:
      0
    case _:
      0

def rhi0(n: U32) -> U32:
  match n:
    case 0:
      2146959360
    case 1:
      2146435072
    case 2:
      0
    case 3:
      1072693248
    case 4:
      2147483648
    case 5:
      0
    case 6:
      0
    case 7:
      2146959360
    case 8:
      2146959360
    case 9:
      1074266112
    case 10:
      1074790399
    case 11:
      1071644672
    case 12:
      1048576
    case 13:
      1071644672
    case 14:
      1071644672
    case 15:
      2146435071
    case 16:
      2146435072
    case 17:
      1072693248
    case 18:
      1072693248
    case 19:
      1018167296
    case 20:
      1128267775
    case 21:
      1074790400
    case 22:
      1073741824
    case 23:
      3221749760
    case 24:
      2145386496
    case 25:
      2145386496
    case _:
      1072693248

def rlo1(n: U32) -> U32:
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
      4294967294
    case 13:
      0
    case 14:
      0
    case 15:
      4294967295
    case 16:
      4294967294
    case 17:
      4294967295
    case 18:
      4294967295
    case 19:
      0
    case 20:
      0
    case 21:
      0
    case 22:
      0
    case 23:
      0
    case 24:
      0
    case 25:
      0
    case _:
      0

def rhi1(n: U32) -> U32:
  match n:
    case 0:
      2146435072
    case 1:
      4293918720
    case 2:
      0
    case 3:
      1072693248
    case 4:
      0
    case 5:
      0
    case 6:
      2147483648
    case 7:
      2146959360
    case 8:
      2146959360
    case 9:
      3192913920
    case 10:
      0
    case 11:
      3219128320
    case 12:
      1048575
    case 13:
      3219128320
    case 14:
      3219128320
    case 15:
      2146435071
    case 16:
      2146435071
    case 17:
      1072693247
    case 18:
      1072693247
    case 19:
      1073741824
    case 20:
      1128267776
    case 21:
      3221225472
    case 22:
      1073741824
    case 23:
      3222536192
    case 24:
      4292870144
    case 25:
      2145386496
    case _:
      3220176896

def rlo2(n: U32) -> U32:
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
      0
    case 7:
      0
    case 8:
      0
    case 9:
      50331648
    case 10:
      4294967294
    case 11:
      0
    case 12:
      0
    case 13:
      0
    case 14:
      2
    case 15:
      0
    case 16:
      0
    case 17:
      0
    case 18:
      1
    case 19:
      1
    case 20:
      0
    case 21:
      0
    case 22:
      0
    case 23:
      0
    case 24:
      0
    case 25:
      0
    case _:
      0

def rhi2(n: U32) -> U32:
  match n:
    case 0:
      4293918720
    case 1:
      2146959360
    case 2:
      0
    case 3:
      0
    case 4:
      0
    case 5:
      2147483648
    case 6:
      2147483648
    case 7:
      2146959360
    case 8:
      2146959360
    case 9:
      1073872896
    case 10:
      1074790399
    case 11:
      524288
    case 12:
      0
    case 13:
      0
    case 14:
      0
    case 15:
      2146435072
    case 16:
      2146435072
    case 17:
      1017118720
    case 18:
      1017118720
    case 19:
      3220176896
    case 20:
      3275751424
    case 21:
      1074266112
    case 22:
      0
    case 23:
      3222274048
    case 24:
      1020264448
    case 25:
      1020788736
    case _:
      524288

def rlo3(n: U32) -> U32:
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
      0
    case 7:
      0
    case 8:
      0
    case 9:
      4205488812
    case 10:
      0
    case 11:
      0
    case 12:
      4294967294
    case 13:
      2
    case 14:
      6
    case 15:
      4294967293
    case 16:
      0
    case 17:
      0
    case 18:
      4294967294
    case 19:
      1
    case 20:
      0
    case 21:
      1431655765
    case 22:
      0
    case 23:
      0
    case 24:
      0
    case 25:
      0
    case _:
      0

def rhi3(n: U32) -> U32:
  match n:
    case 0:
      2146959360
    case 1:
      0
    case 2:
      2146959360
    case 3:
      2146435072
    case 4:
      2146959360
    case 5:
      2146959360
    case 6:
      2146959360
    case 7:
      2146959360
    case 8:
      2146959360
    case 9:
      1072693247
    case 10:
      1072693248
    case 11:
      2097152
    case 12:
      1127219199
    case 13:
      0
    case 14:
      0
    case 15:
      2146435071
    case 16:
      1128267776
    case 17:
      1128267776
    case 18:
      1128267775
    case 19:
      3220176896
    case 20:
      3275751424
    case 21:
      1070945621
    case 22:
      2146435072
    case 23:
      3222274048
    case 24:
      0
    case 25:
      2146435072
    case _:
      524288

def rlo4(n: U32) -> U32:
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
      0
    case 7:
      0
    case 8:
      0
    case 9:
      336142638
    case 10:
      1719614412
    case 11:
      0
    case 12:
      4294967295
    case 13:
      0
    case 14:
      3898100906
    case 15:
      4294967295
    case 16:
      4294967295
    case 17:
      0
    case 18:
      0
    case 19:
      0
    case 20:
      1719614413
    case 21:
      0
    case 22:
      1719614413
    case 23:
      0
    case 24:
      1719614413
    case 25:
      1719614413
    case _:
      1719614413

def rhi4(n: U32) -> U32:
  match n:
    case 0:
      2146435072
    case 1:
      0
    case 2:
      0
    case 3:
      1072693248
    case 4:
      2147483648
    case 5:
      0
    case 6:
      2147483648
    case 7:
      2146959360
    case 8:
      2146959360
    case 9:
      1072928910
    case 10:
      1073127582
    case 11:
      536870912
    case 12:
      536870911
    case 13:
      509607936
    case 14:
      510375546
    case 15:
      1609564159
    case 16:
      1609564159
    case 17:
      1072693248
    case 18:
      1072693248
    case 19:
      1072693248
    case 20:
      1100390558
    case 21:
      1072693248
    case 22:
      1073127582
    case 23:
      2146959360
    case 24:
      510042270
    case 25:
      1608949918
    case _:
      536256670

def fa(+i: U32) -> F64:
  F64.from_bits(U64.join(alo(i), ahi(i)))

def fb(+i: U32) -> F64:
  F64.from_bits(U64.join(blo(i), bhi(i)))

def ok0(+i: U32) -> U32:
  +r = F64.bits(F64.add(fa(i), fb(i)))
  Bool.to_u32(Bool.and(U32.is_eq(U64.lo(r), rlo0(i)),
    U32.is_eq(U64.hi(r), rhi0(i))))

def kept0(+n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      U32.add(kept0(p), ok0(U32.from_nat(p)))

def ok1(+i: U32) -> U32:
  +r = F64.bits(F64.sub(fa(i), fb(i)))
  Bool.to_u32(Bool.and(U32.is_eq(U64.lo(r), rlo1(i)),
    U32.is_eq(U64.hi(r), rhi1(i))))

def kept1(+n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      U32.add(kept1(p), ok1(U32.from_nat(p)))

def ok2(+i: U32) -> U32:
  +r = F64.bits(F64.mul(fa(i), fb(i)))
  Bool.to_u32(Bool.and(U32.is_eq(U64.lo(r), rlo2(i)),
    U32.is_eq(U64.hi(r), rhi2(i))))

def kept2(+n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      U32.add(kept2(p), ok2(U32.from_nat(p)))

def ok3(+i: U32) -> U32:
  +r = F64.bits(F64.div(fa(i), fb(i)))
  Bool.to_u32(Bool.and(U32.is_eq(U64.lo(r), rlo3(i)),
    U32.is_eq(U64.hi(r), rhi3(i))))

def kept3(+n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      U32.add(kept3(p), ok3(U32.from_nat(p)))

def ok4(+i: U32) -> U32:
  +r = F64.bits(F64.sqrt(fa(i)))
  Bool.to_u32(Bool.and(U32.is_eq(U64.lo(r), rlo4(i)),
    U32.is_eq(U64.hi(r), rhi4(i))))

def kept4(+n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      U32.add(kept4(p), ok4(U32.from_nat(p)))

def main() -> IO(Unit):
  IO.print(U32.show(kept0(27n)) ++ " " ++ U32.show(kept1(27n)) ++ " "
    ++ U32.show(kept2(27n)) ++ " " ++ U32.show(kept3(27n)) ++ " "
    ++ U32.show(kept4(27n)))

#|27 27 27 27 27
