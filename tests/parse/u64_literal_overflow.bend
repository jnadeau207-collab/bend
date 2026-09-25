import Base

def main() -> U64:
  18446744073709551616u64

#|Error:
#|- expected : a u64 literal up to 18446744073709551615 (got 18446744073709551616u64)
#|- observed : '
#|'
#|Location:
#|3 | def main() -> U64:
#|4>|   18446744073709551616u64
#|5 |
#|exit 1
