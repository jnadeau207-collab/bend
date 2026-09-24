# a ( .. : T) names the operators of its own operator expression and none
# inside a nested term, so an operator in a ~ argument is annotated there:
# the instance and the caller's copy then agree
import Base

def T(~f: U32 -> U32, x: U32) -> U32:
  f(x)

def main() -> IO(Unit):
  IO.print(U32.show(T(~(x => (x + 1 : U32)), 41)))

#|42
