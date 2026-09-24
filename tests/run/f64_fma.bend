# F64's fma, bit-exact against the host's correctly-rounded fma (a NaN
# the canonical 0x7ff8000000000000): exact small products, a rounding
# case, exact and near cancellation, overflow with a zero and a finite
# addend, the subnormal edge both ways, 0 * inf, the infinite sums, a
# signed-zero product, the far paths both ways, a NaN input, an
# infinite addend over an overflowing product and sticky-sensitive wide
# sums. The interpreter runs
# Base's software core; C runs libc's fma, JS and the device lanes the
# core; the count is of the vectors kept.
import Base

def alo(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      2576980378
    case 2:
      0
    case 3:
      1
    case 4:
      4294967295
    case 5:
      4294967295
    case 6:
      1
    case 7:
      1
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
      4294967295
    case 16:
      4294967295
    case 17:
      4294967290
    case 18:
      4294967295
    case 19:
      4294967295
    case _:
      4294967295

def ahi(n: U32) -> U32:
  match n:
    case 0:
      1073741824
    case 1:
      1069128089
    case 2:
      1072693248
    case 3:
      1072693248
    case 4:
      2146435071
    case 5:
      2146435071
    case 6:
      0
    case 7:
      0
    case 8:
      2146435072
    case 9:
      4293918720
    case 10:
      2146435072
    case 11:
      0
    case 12:
      1072693248
    case 13:
      1585446912
    case 14:
      2146697216
    case 15:
      2146435071
    case 16:
      2146435071
    case 17:
      1048575
    case 18:
      1048575
    case 19:
      1048575
    case _:
      1048575

def blo(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      2576980378
    case 2:
      0
    case 3:
      1
    case 4:
      4294967295
    case 5:
      4294967295
    case 6:
      1
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
      0
    case 15:
      4294967295
    case 16:
      4294967295
    case 17:
      4294967292
    case 18:
      4294967295
    case 19:
      4294967295
    case _:
      4294967295

def bhi(n: U32) -> U32:
  match n:
    case 0:
      1074266112
    case 1:
      1070176665
    case 2:
      1072693248
    case 3:
      1072693248
    case 4:
      2146435071
    case 5:
      2146435071
    case 6:
      0
    case 7:
      1072693248
    case 8:
      0
    case 9:
      1072693248
    case 10:
      1073741824
    case 11:
      1075052544
    case 12:
      1072693248
    case 13:
      1585446912
    case 14:
      1072693248
    case 15:
      2146435071
    case 16:
      2146435071
    case 17:
      2145386495
    case 18:
      2145386495
    case 19:
      2145386495
    case _:
      2146435071

def clo(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      858993459
    case 2:
      0
    case 3:
      2
    case 4:
      0
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
      1
    case 18:
      0
    case 19:
      4
    case _:
      0

def chi(n: U32) -> U32:
  match n:
    case 0:
      1074790400
    case 1:
      1070805811
    case 2:
      3220176896
    case 3:
      3221225472
    case 4:
      0
    case 5:
      4293918719
    case 6:
      0
    case 7:
      1048575
    case 8:
      1072693248
    case 9:
      4293918720
    case 10:
      4293918720
    case 11:
      2147483648
    case 12:
      896532480
    case 13:
      1016070144
    case 14:
      1073741824
    case 15:
      2146435072
    case 16:
      4293918720
    case 17:
      1072693248
    case 18:
      1072693248
    case 19:
      1072693248
    case _:
      1072693248

def rlo(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      1202590843
    case 2:
      0
    case 3:
      2
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
      4294967289
    case 18:
      4294967295
    case 19:
      1
    case _:
      4294967295

def rhi(n: U32) -> U32:
  match n:
    case 0:
      1076101120
    case 1:
      1070889697
    case 2:
      0
    case 3:
      3220176896
    case 4:
      2146435072
    case 5:
      2146435072
    case 6:
      0
    case 7:
      1048576
    case 8:
      2146959360
    case 9:
      4293918720
    case 10:
      2146959360
    case 11:
      0
    case 12:
      1072693248
    case 13:
      2098200576
    case 14:
      2146959360
    case 15:
      2146435072
    case 16:
      4293918720
    case 17:
      1074266111
    case 18:
      1074266111
    case 19:
      1074266112
    case _:
      1075052543

def fa(+i: U32) -> F64:
  F64.from_bits(U64.join(alo(i), ahi(i)))

def fb(+i: U32) -> F64:
  F64.from_bits(U64.join(blo(i), bhi(i)))

def fc(+i: U32) -> F64:
  F64.from_bits(U64.join(clo(i), chi(i)))

def ok(+i: U32) -> U32:
  +r = F64.bits(F64.fma(fa(i), fb(i), fc(i)))
  Bool.to_u32(Bool.and(U32.is_eq(U64.lo(r), rlo(i)),
    U32.is_eq(U64.hi(r), rhi(i))))

def kept(+n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      U32.add(kept(p), ok(U32.from_nat(p)))

def main() -> IO(Unit):
  IO.print(U32.show(kept(21n)))

#|21
