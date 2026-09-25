import math, re, struct, sys
from fractions import Fraction as Q
import numpy as np

M = (1 << 64) - 1
G = 0x9E3779B97F4A7C15
SIGN, MANT = 1 << 63, (1 << 52) - 1
NAN = 0x7FF8000000000000


def mix(z):
    z = ((z ^ (z >> 30)) * 0xBF58476D1CE4E5B9) & M
    z = ((z ^ (z >> 27)) * 0x94D049BB133111EB) & M
    return z ^ (z >> 31)


def gen(z):
    m, e = (z >> 1) & 3, (z >> 52) & 2047
    t = e & 3
    ex = e if m == 0 else (t + (2044 if t >= 2 else 0)) if m == 3 else 990 + (e & 63)
    mant = 0 if m == 3 and e & 32 == 0 else z & MANT
    return (z & SIGN) | mant | (ex << 52)


f = lambda b: struct.unpack('<d', struct.pack('<Q', b))[0]
raw = lambda x: struct.unpack('<Q', struct.pack('<d', x))[0]


def bits(x):
    return NAN if math.isnan(x) else raw(x)


def rnd(q, neg):
    if q == 0:
        return -0.0 if neg else 0.0
    try:
        return float(q)
    except OverflowError:
        return -math.inf if q < 0 else math.inf


def fma(a, b, c):
    if math.isnan(a) or math.isnan(b) or math.isnan(c):
        return math.nan
    if math.isinf(a) or math.isinf(b):
        if a == 0 or b == 0:
            return math.nan
        p = math.copysign(math.inf, a) * math.copysign(1, b)
        return math.nan if math.isinf(c) and c != p else p
    if math.isinf(c):
        return c
    q = Q(a) * Q(b) + Q(c)
    if q == 0:
        return rnd(q, math.copysign(1, a) * math.copysign(1, b) < 0 and math.copysign(1, c) < 0)
    return rnd(q, False)


def div(a, b):
    with np.errstate(all='ignore'):
        return float(np.float64(a) / np.float64(b))


def sqrt(a):
    with np.errstate(all='ignore'):
        return float(np.sqrt(np.float64(a)))


def to_u64(a):
    return 0 if math.isnan(a) or a < 0 or a >= 2.0 ** 64 else int(a)


def to_f32(a):
    if math.isnan(a):
        return 0x7FC00000
    with np.errstate(all='ignore'):
        return int(np.float32(a).view(np.uint32))


f32 = lambda u: float(np.uint32(u).view(np.float32))
mn = lambda a, b: a if a < b else b
mx = lambda a, b: b if a < b else a
B = lambda c: 1 if c else 0
clz = lambda u: 64 - u.bit_length()

OPS = {
    'add': ('F64.bits(F64.add(a, b))', lambda a, b, c, x, y: bits(fma(a, 1.0, b))),
    'sub': ('F64.bits(F64.sub(a, b))', lambda a, b, c, x, y: bits(fma(a, 1.0, -b))),
    'subc': ('F64.bits(F64.sub(a, F64{U64.xor(F64.bits(a), U64.and(y, 65535u64))}))',
             lambda a, b, c, x, y: bits(fma(a, 1.0, -f(bits(a) ^ (y & 65535))))),
    'mul': ('F64.bits(F64.mul(a, b))', lambda a, b, c, x, y: bits(fma(a, b, -0.0))),
    'div': ('F64.bits(F64.div(a, b))', lambda a, b, c, x, y: bits(div(a, b))),
    'fma': ('F64.bits(F64.fma(a, b, c))', lambda a, b, c, x, y: bits(fma(a, b, c))),
    'fmac': ('F64.bits(F64.fma(a, b, F64{U64.xor(F64.bits(F64.neg(F64.mul(a, b))), U64.and(y, 255u64))}))',
             lambda a, b, c, x, y: bits(fma(a, b, f(bits(-fma(a, b, -0.0)) ^ (y & 255))))),
    'sqrt': ('F64.bits(F64.sqrt(a))', lambda a, b, c, x, y: bits(sqrt(a))),
    'cmp': ('U64.or(U64.or(Bool.to_u64(F64.is_eq(a, b)), U64.shl(Bool.to_u64(F64.is_lt(a, b)))), U64.shln(Bool.to_u64(F64.is_le(a, b)), 2n))',
            lambda a, b, c, x, y: B(a == b) | B(a < b) << 1 | B(a <= b) << 2),
    'cmpz': ('U64.or(Bool.to_u64(F64.is_eq(a, F64.neg(a))), U64.shl(Bool.to_u64(F64.is_ge(a, F64{U64.xor(F64.bits(a), 1u64)}))))',
             lambda a, b, c, x, y: B(a == -a) | B(a >= f(bits(a) ^ 1)) << 1 if not math.isnan(a) else 0),
    'minmax': ('U64.xor(F64.bits(F64.min(a, b)), U64.mul(F64.bits(F64.max(a, b)), 3u64))',
               lambda a, b, c, x, y: (raw(mn(a, b)) ^ raw(mx(a, b)) * 3) & M),
    'to_u64': ('U64.xor(F64.to_u64(a), F64.to_u64(F64.abs(a)))', lambda a, b, c, x, y: to_u64(a) ^ to_u64(abs(a))),
    'to_u32': ('U32.to_u64(F64.to_u32(F64.abs(a)))',
               lambda a, b, c, x, y: (lambda u: u if u < 2 ** 32 else 0)(to_u64(abs(a)))),
    'to_f32': ('U32.to_u64(f32bits(F64.to_f32(a)))', lambda a, b, c, x, y: to_f32(a)),
    'u64_f64': ('F64.bits(U64.to_f64(U64.shrn(x, U32.to_nat(U64.to_u32(U64.and(y, 63u64))))))',
                lambda a, b, c, x, y: bits(float(x >> (y & 63)))),
    'u32_f64': ('F64.bits(U32.to_f64(U64.to_u32(x)))', lambda a, b, c, x, y: bits(float(x & 0xFFFFFFFF))),
    'f32_f64': ('F64.bits(F32.to_f64(F32.from_bits(U64.to_u32(x))))',
                lambda a, b, c, x, y: bits(f32(x & 0xFFFFFFFF)) if not math.isnan(f32(x & 0xFFFFFFFF)) else NAN),
    'negabs': ('U64.add(F64.bits(F64.neg(a)), F64.bits(F64.abs(b)))',
               lambda a, b, c, x, y: ((raw(a) ^ SIGN) + (raw(b) & ~SIGN)) & M),
    'u_arith': ('U64.xor(U64.xor(U64.add(x, y), U64.sub(x, y)), U64.xor(U64.mul(x, y), U64.mul_hi(x, y)))',
                lambda a, b, c, x, y: ((x + y) & M) ^ ((x - y) & M) ^ ((x * y) & M) ^ ((x * y) >> 64)),
    'u_divmod': ('U64.add(U64.div(x, U64.shrn(y, U32.to_nat(U64.to_u32(U64.and(x, 63u64))))), U64.mul(U64.mod(x, U64.shrn(y, U32.to_nat(U64.to_u32(U64.and(y, 63u64))))), 7u64))',
                 lambda a, b, c, x, y: ((lambda d: x // d if d else 0)(y >> (x & 63)) + 7 * (lambda d: x % d if d else x)(y >> (y & 63))) & M),
    'u_bits': ('U64.xor(U64.xor(U64.and(x, y), U64.or(U64.not(x), U64.shl(y))), U64.xor(U64.shln(x, U32.to_nat(U64.to_u32(U64.and(y, 127u64)))), U64.shr(y)))',
               lambda a, b, c, x, y: (x & y) ^ ((~x | (y << 1)) & M) ^ ((x << (y & 127)) & M if (y & 127) < 64 else 0) ^ (y >> 1)),
    'u_cmp': ('U64.add(U32.to_u64(U64.clz(U64.shrn(x, U32.to_nat(U64.to_u32(U64.and(y, 63u64)))))), U64.add(U64.shln(Bool.to_u64(U64.is_lt(x, y)), 8n), U64.min(x, y)))',
              lambda a, b, c, x, y: (clz(x >> (y & 63)) + (B(x < y) << 8) + min(x, y)) & M),
}


def case(op, i):
    r1 = mix(i * G & M)
    r2 = mix((r1 + G) & M)
    r3 = mix((r2 + G) & M)
    return OPS[op][1](f(gen(r1)), f(gen(r2)), f(gen(r3)), r1, r2)


def wave(op, d, i):
    return case(op, i) if d == 0 else (wave(op, d - 1, 2 * i) * 31 + wave(op, d - 1, 2 * i + 1)) & M


PRE = '''import Base

def mix(+z: U64) -> U64:
  +a = U64.mul(U64.xor(z, U64.shrn(z, 30n)), 13787848793156543929u64)
  +b = U64.mul(U64.xor(a, U64.shrn(a, 27n)), 10723151780598845931u64)
  U64.xor(b, U64.shrn(b, 31n))

def gen(+z: U64) -> F64:
  +m = U64.and(U64.shrn(z, 1n), 3u64)
  +e = U64.and(U64.shrn(z, 52n), 2047u64)
  +t = U64.and(e, 3u64)
  +sp = U64.add(t, U64.mul(Bool.to_u64(U64.is_ge(t, 2u64)), 2044u64))
  +ex = Bool.pick(U64, U64.is_eq(m, 0u64), e, Bool.pick(U64, U64.is_eq(m, 3u64), sp, U64.add(990u64, U64.and(e, 63u64))))
  +mant = Bool.pick(U64, Bool.and(U64.is_eq(m, 3u64), U64.is_eq(U64.and(e, 32u64), 0u64)), 0u64, U64.and(z, 4503599627370495u64))
  F64{U64.or(U64.or(U64.and(z, 9223372036854775808u64), mant), U64.shln(ex, 52n))}

def f32bits(f: F32) -> U32:
  F32{w} = f
  U32{w}
'''


def bend(d, bang):
    out = [PRE]
    for op, (expr, _) in OPS.items():
        out.append(f'''law l_{op}:
  for +i: U64
  U64

def l_{op}(i):
  +r1 = mix(U64.mul(i, 11400714819323198485u64))
  +r2 = mix(U64.add(r1, 11400714819323198485u64))
  +r3 = mix(U64.add(r2, 11400714819323198485u64))
  +a = gen(r1)
  +b = gen(r2)
  +c = gen(r3)
  +x = r1
  +y = r2
  {expr}

law w_{op}:
  for +d: Nat
  for +i: U64
  U64

def w_{op}(d, i):
  match d:
    case 0n:
      l_{op}(i)
    case 1n+p:
      a b = w_{op}(p, U64.shl(i)) w_{op}(p, U64.inc(U64.shl(i)))
      U64.add(U64.mul(a, 31u64), b)
''')
    if bang:
        prints = ''.join(f'    Unit <- IO.print(U64.show(w_{op}!({d}n, 0u64)))\n' for op in OPS)
        out.append(f'law main:\n  IO(Unit)\n\ndef main():\n  do IO<Unit>:\n{prints}    IO.pure(Unit, Unit{{}})\n')
    else:
        out.append('def main() -> List<U64>:\n  [' + ', '.join(f'w_{op}({d}n, 0u64)' for op in OPS) + ']\n')
    return '\n'.join(out)


def ints(s):
    return [int(x) for x in re.findall(r'\d+', s.replace('u64', ''))]


if __name__ == '__main__':
    if sys.argv[1] == 'check':
        want, got = (ints(open(p).read()) for p in sys.argv[2:4])
        bad = [op for i, op in enumerate(OPS) if i >= len(got) or got[i] != want[i]]
        print(f'{len(OPS)} groups, ' + (f'mismatches: {" ".join(bad)}' if bad or len(got) != len(want) else '0 mismatches'))
        sys.exit(1 if bad or len(got) != len(want) else 0)
    d, path = int(sys.argv[1]), sys.argv[2]
    open(path, 'w', newline='\n').write(bend(d, sys.argv[3:] != ['flat']))
    print(' '.join(str(wave(op, d, 0)) for op in OPS))
