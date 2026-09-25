import sys
from diff import G, M, gen, mix
from probes import NAN, S, bits, f, show

LITS = [
    '2.2250738585072011e-308', '2.2250738585072012e-308', '2.2250738585072014e-308',
    '4.9406564584124654e-324', '2.4703282292062327e-324', '2.4703282292062328e-324',
    '1.7976931348623157e308', '1.7976931348623158e308', '8.98846567431158e307',
    '9007199254740993.0', '9007199254740995.0', '9007199254740993.000000000000000000001',
    '0.1', '0.2', '0.3', '1.0e23', '1.0e-320', '5.0e-324', '7.2057594037927933e16',
    '0.1000000000000000055511151231257827021181583404541015625',
    '0.1000000000000000055511151231257827021181583404541015624',
    '0.1000000000000000055511151231257827021181583404541015626',
    '1.00000000000000011102230246251565404236316680908203125',
    '1.00000000000000011102230246251565404236316680908203124',
    '1.00000000000000011102230246251565404236316680908203126',
    '123456789012345678901234567890.0', '3.14159265358979323846264338327950288419716939937510',
    '2.718281828459045235360287471352662497757', '4.35679196e-311', '6.9294956446009195e15',
    '3.0e-44', '1.8014398509481985e16', '9.5e-5', '1.0e21', '1.0e-7', '0.000001', '0.0']

SPECIALS = [0, S, 0x7FF0000000000000, 0xFFF0000000000000, NAN, 0xFFF8000000000123, 0x7FF0000000000001,
            0x7FEFFFFFFFFFFFFF, 0x0010000000000000, 0x000FFFFFFFFFFFFF, 1]


def values():
    powers = [bits(2.0 ** e) for e in range(-1074, 1024)]
    return SPECIALS + powers + [bits(float(s)) for s in LITS] + [gen(mix(i * G & M)) for i in range(1024)]


def program():
    xs = ', '.join(f'{b}u64' for b in values())
    lits = ' ++ " " ++ '.join(f'U64.show(F64.bits({s}f64)) ++ " " ++ back(F64.read("{s}"))' for s in LITS)
    return f'''import Base

def xs() -> List<U64>:
  [{xs}]

def back(m: Maybe<&2, F64>) -> String:
  match m:
    case Some{{v}}:
      U64.show(F64.bits(v))
    case None{{}}:
      "none"

def line(+x: F64) -> String:
  F64.show(x) ++ " " ++ back(F64.read(F64.show(x)))

law lines:
  for xs: List<U64>
  String

def lines(xs):
  match xs:
    case Nil{{}}:
      "|"
    case Con{{h, t}}:
      line(F64{{h}}) ++ " " ++ lines(t)

def main() -> String:
  lines(xs()) ++ " " ++ {lits} ++ " |"
'''


def want():
    shown = [show(f(b)) for b in values()]
    return [[t for s in shown for t in (s, str(bits(float(s))))],
            [str(bits(float(s))) for s in LITS for _ in (0, 1)]]


if __name__ == '__main__':
    if sys.argv[1] == 'write':
        open(sys.argv[2], 'w', newline='\n').write(program())
        sys.exit(0)
    got = [g.split() for g in open(sys.argv[2]).read().strip().strip('"').split('|')[:-1]]
    exp = want()
    bad = [(i, j, w, g) for i, (ws, gs) in enumerate(zip(exp, got)) for j, (w, g) in enumerate(zip(ws, gs)) if w != g]
    ok = len(got) == 2 and all(len(g) == len(w) for g, w in zip(got, exp)) and not bad
    print(f'{len(exp[0]) // 2} values shown and read back, {len(LITS)} decimal literals and reads: '
          + ('0 mismatches' if ok else f'mismatches {bad[:4]}' if bad else 'wrong shape'))
    sys.exit(0 if ok else 1)
