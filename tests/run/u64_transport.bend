# A U64 keeps all 64 bits on every lane: each pattern is a word the C
# runtime could read as its own (2^32, 2^48, 2^53 +- 1, RFC_BIT 2^63,
# TERM_HOLE 2^64-1, a CTR, ARR or RFC'd CLO tag byte) and rides each
# carrier (a return, a record, a tuple, a Maybe, a boxing generic, a
# List, an Array read and swap, a closure, a recursion, a fork, its own
# bits, a static record) back to its halves: each count is of 12 kept.
import Base

def lo(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      1
    case 2:
      0
    case 3:
      0
    case 4:
      4294967295
    case 5:
      0
    case 6:
      1
    case 7:
      0
    case 8:
      4294967295
    case 9:
      4660
    case 10:
      1
    case _:
      7

def hi(n: U32) -> U32:
  match n:
    case 0:
      0
    case 1:
      0
    case 2:
      1
    case 3:
      65536
    case 4:
      2097151
    case 5:
      2097152
    case 6:
      2097152
    case 7:
      2147483648
    case 8:
      4294967295
    case 9:
      33554432
    case 10:
      100663296
    case _:
      2197815296

def pat(+n: U32) -> U64:
  U64.join(lo(n), hi(n))

# checked against the halves as U32s, not against another U64, so a lane
# that cut or packed both sides alike still fails
def same(+a: U64, +n: U32) -> Bool:
  Bool.and(U32.is_eq(U64.lo(a), lo(n)), U32.is_eq(U64.hi(a), hi(n)))

type Rec is Data:
  Rec{a: U32, b: U64, c: Bool}

def rec.get(r: Rec) -> U64:
  match r:
    case Rec{a, b, c}:
      b

def tup.get(t: U32 & U64) -> U64:
  (a, b) = t
  b

def may.get(m: Maybe<&1, U64>) -> U64:
  match m:
    case None{}:
      U64.join(9, 9)
    case Some{x}:
      x

def poly(-A: Type, x: A) -> A:
  x

def lst.get(l: List<&1, U64>) -> U64:
  match l:
    case Con{h, t}:
      match t:
        case Con{x, r}:
          x
        case Nil{}:
          h
    case Nil{}:
      U64.join(9, 9)

def arr.get(r: Array<U64> & U64) -> U64:
  (a, x) = r
  x

def arr.swap(x: U64) -> U64:
  arr.get(Array.swap(U64, Array.new(U64, 2n, x), 2, U64.join(9, 9)))

def arr.back(r: Array<U64> & U64) -> U64:
  (a, o) = r
  arr.get(Array.get(U64, a, 2))

def app(f: U32 -> U64, a: U32) -> U64:
  f(a)

def deep(n: Nat, x: U64) -> U64:
  match n:
    case 0n:
      x
    case 1n+p:
      deep(p, x)

def fork(x: U64) -> U64:
  a b = deep(8n, x) deep(8n, U64.join(9, 9))
  a

def rewrap(a: U64) -> U64:
  U64{w} = a
  U64{w}

def stat() -> Rec:
  Rec{3, U64.join(0, 2147483648), True{}}

def carry(k: U32, x: U64) -> U64:
  match k:
    case 0:
      x
    case 1:
      rec.get(Rec{7, x, True{}})
    case 2:
      tup.get((7, x))
    case 3:
      may.get(Some{x})
    case 4:
      poly(U64, x)
    case 5:
      lst.get(Con{U64.join(9, 9), Con{x, Nil{}}})
    case 6:
      arr.get(Array.get(U64, Array.new(U64, 3n, x), 5))
    case 7:
      arr.swap(x)
    case 8:
      arr.back(Array.swap(U64, Array.new(U64, 2n, U64.join(9, 9)), 2, x))
    case 9:
      app(u => x, 0)
    case 10:
      deep(64n, x)
    case 11:
      fork(x)
    case _:
      rewrap(x)

def kept(+k: U32, +n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      +i = U32.from_nat(p)
      U32.add(Bool.to_u32(same(carry(k, pat(i)), i)), kept(k, p))

def lines(+k: Nat) -> String:
  match k:
    case 0n:
      ""
    case 1n+p:
      lines(p) ++ U32.show(kept(U32.from_nat(p), 12n)) ++ " "

def main() -> IO(Unit):
  IO.print(lines(13n) ++ U32.show(Bool.to_u32(same(rec.get(stat()), 7))))

#|12 12 12 12 12 12 12 12 12 12 12 12 12 1
