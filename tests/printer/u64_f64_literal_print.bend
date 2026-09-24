# a u64 or f64 literal is one Lit of its bits (hex or decimal, the f64
# exactly rounded); a pure main prints each back on every lane as it reads
# again: NNNu64, and the shortest decimal that reads back, with a point
import Base

def main() -> (U64 & U64 & U64) & (F64 & F64 & F64 & F64 & F64 & F64):
  ((18446744073709551615u64, 0x7ff0000000000001u64, 0u64),
   (0.1f64, 1.0e300f64, 4.9406564584124654e-324f64, F64.neg(0f64),
    123456789012345678f64, 2.2250738585072011e-308f64))

#|((18446744073709551615u64, 9218868437227405313u64, 0u64), 0.1f64, 1.0e+300f64, 5.0e-324f64, -0.0f64, 123456789012345680.0f64, 2.225073858507201e-308f64)
