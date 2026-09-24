# f64 text: show is the shortest decimal that reads back on every
# lane (C's f32_text at 17 digits, JS's f64_show), read strtod's grammar
# behind a whole-string gate: fractions, an integer, the exponent edges,
# the subnormal floor, signed zero, infinities and NaN round-trip, while
# a non-number and the empty string answer None
import Base

law seen:
  for m: Maybe<&2, F64>
  String

def seen(m):
  match m:
    case None{}:
      "none"
    case Some{v}:
      F64.show(v)

law main.out:
  String

def main.out():
  a = F64.show(0.1f64)
  b = F64.show(100.0f64)
  c = F64.show(1.0e300f64)
  d = F64.show(4.9406564584124654e-324f64)
  e = F64.show(2.2250738585072014e-308f64)
  f = F64.show(F64.neg(0f64))
  g = F64.show(F64.div(1f64, 0f64))
  h = F64.show(F64.div(0f64, 0f64))
  i = F64.show(123456789012345678f64)
  j = F64.show(F64.div(1f64, 3f64))
  k = F64.show(1.0e-7f64)
  l = F64.show(1.0e21f64)
  m = F64.show(0.0009765625f64)
  n = F64.show(123456.789f64)
  o = seen(F64.read("2.5"))
  p = seen(F64.read("hi"))
  q = seen(F64.read(""))
  r = seen(F64.read(F64.show(1.25f64)))
  a ++ "|" ++ b ++ "|" ++ c ++ "|" ++ d ++ "|" ++ e ++ "|" ++ f ++ "|" ++ g
    ++ "|" ++ h ++ "|" ++ i ++ "|" ++ j ++ "|" ++ k ++ "|" ++ l ++ "|" ++ m
    ++ "|" ++ n ++ "|" ++ o ++ "|" ++ p ++ "|" ++ q ++ "|" ++ r

law main:
  IO(Unit)

def main():
  IO.print(main.out())

#|0.1|100|1e+300|5e-324|2.2250738585072014e-308|-0|inf|nan|123456789012345680|0.3333333333333333|1e-7|1e+21|0.0009765625|123456.789|2.5|none|none|1.25
