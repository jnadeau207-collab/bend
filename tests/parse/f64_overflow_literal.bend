# an f64 literal rounds exactly; one past the largest finite is an error
import Base

def main() -> F64:
  1.7976931348623159e308f64

#|Error:
#|- expected : a u64 literal up to 18446744073709551615u64 or a finite decimal f64 literal (got 1.7976931348623159e308f64)
#|- observed : '
#|'
#|Location:
#|4 | def main() -> F64:
#|5>|   1.7976931348623159e308f64
#|6 |
#|exit 1
