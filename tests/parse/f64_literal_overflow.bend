import Base

def main() -> F64:
  1.0e309f64

#|Error:
#|- expected : a float literal with a finite f64 value (got 1.0e309f64)
#|- observed : '
#|'
#|Location:
#|3 | def main() -> F64:
#|4>|   1.0e309f64
#|5 |
#|exit 1
