import math, struct, sys
import numpy as np

M = (1 << 64) - 1
S = 1 << 63
NAN = 0x7FF8000000000000
f = lambda b: struct.unpack('<d', struct.pack('<Q', b))[0]
raw = lambda x: struct.unpack('<Q', struct.pack('<d', x))[0]
bits = lambda x: NAN if math.isnan(x) else raw(x)


def show(x):
    if math.isnan(x):
        return 'nan'
    if math.isinf(x):
        return 'inf' if x > 0 else '-inf'
    if x == 0:
        return '-0' if math.copysign(1, x) < 0 else '0'
    m, _, e = repr(abs(x)).partition('e')
    ip, _, fp = m.partition('.')
    ds = ip + fp
    n = len(ip) + int(e or 0) - (len(ds) - len(ds.lstrip('0')))
    ds = ds.strip('0')
    k = len(ds)
    if k <= n <= 21:
        s = ds + '0' * (n - k)
    elif 0 < n <= 21:
        s = ds[:n] + '.' + ds[n:]
    elif -6 < n <= 0:
        s = '0.' + '0' * -n + ds
    else:
        s = ds[0] + ('.' + ds[1:] if k > 1 else '') + 'e' + ('+' if n > 0 else '-') + str(abs(n - 1))
    return ('-' if x < 0 else '') + s


def to_u64(x):
    return 0 if math.isnan(x) or math.isinf(x) or x < 0 or x >= 2.0 ** 64 else int(x)


def to_f32(x):
    if math.isnan(x):
        return 0x7FC00000
    with np.errstate(all='ignore'):
        return int(np.float32(x).view(np.uint32))


def cmp6(a, b):
    return (a == b) | (a != b) << 1 | (a < b) << 2 | (a <= b) << 3 | (a > b) << 4 | (a >= b) << 5


def f64():
    vs = [0x0, S, 0x1, 0x000FFFFFFFFFFFFF, 0x0010000000000000, 0x3FF0000000000000,
          0x3FB999999999999A, 0x7FEFFFFFFFFFFFFF, 0x7FF0000000000000, 0xFFF0000000000000,
          0x7FF8000000000000, 0x7FF8000000000123, 0x7FF0000000000001, 0xFFF4000000000000,
          M, 0x43F0000000000000, 0x43EFFFFFFFFFFFFF, 0xC000000000000000, 0x4340000000000001,
          0x41EFFFFFFFE00000]
    ks = [lambda b, x: b] * 8 + [
        lambda b, x: b ^ S, lambda b, x: b & ~S & M, lambda b, x: bits(x + 1.0),
        lambda b, x: bits(x * x), lambda b, x: bits(x / 3.0),
        lambda b, x: bits(math.nan if math.isnan(x) or x < 0 else math.sqrt(x)),
        lambda b, x: bits(x - x), lambda b, x: cmp6(x, x), lambda b, x: cmp6(x, 1.0),
        lambda b, x: cmp6(x, -0.0), lambda b, x: to_u64(x),
        lambda b, x: (lambda u: u if u < 2 ** 32 else 0)(to_u64(x)), lambda b, x: to_f32(x),
        lambda b, x: bits(float(to_u64(x)))]
    names = ['id', 'ctor', 'pair', 'maybe', 'array', 'closure', 'pick', 'bang', 'neg', 'abs', 'add1',
             'mul', 'div3', 'sqrt', 'sub_self', 'cmp_self', 'cmp_one', 'cmp_negzero', 'to_u64', 'to_u32',
             'to_f32', 'u64_f64']
    groups = [[str(k(b, f(b))) for b in vs] for k in ks]
    return names + ['show'], groups + [[show(f(b)) for b in vs]]


def u64ops():
    vs = [0, 1, 2 ** 32 - 1, 2 ** 32, 2 ** 63, 2 ** 64 - 1, 12345678901234567890]
    sh = lambda a, b: (a << (b & 127)) & M if (b & 127) < 64 else 0
    bins = {'add': lambda a, b: (a + b) & M, 'sub': lambda a, b: (a - b) & M, 'mul': lambda a, b: (a * b) & M,
            'mul_hi': lambda a, b: (a * b) >> 64, 'div': lambda a, b: a // b if b else 0,
            'mod': lambda a, b: a % b if b else a, 'and': lambda a, b: a & b, 'or': lambda a, b: a | b,
            'xor': lambda a, b: a ^ b, 'is_lt': lambda a, b: int(a < b), 'is_eq': lambda a, b: int(a == b),
            'shln': sh, 'shrn': lambda a, b: a >> (b & 127) if (b & 127) < 64 else 0, 'min': min, 'max': max}
    uns = {'clz': lambda a: 64 - a.bit_length(), 'not': lambda a: ~a & M, 'shl': lambda a: (a << 1) & M,
           'shr': lambda a: a >> 1, 'inc': lambda a: (a + 1) & M, 'to_u32': lambda a: a & 0xFFFFFFFF,
           'to_f64': lambda a: raw(float(a)), 'is_zero': lambda a: int(a == 0)}
    groups = [[str(g(a, b)) for a in vs for b in vs] for g in bins.values()]
    return list(bins) + list(uns), groups + [[str(g(a)) for a in vs] for g in uns.values()]


def u64():
    vs = [0, 1, 4294967296, 281474976710656, 9007199254740991, 9007199254740992, 9007199254740993,
          9223372036854775808, 18446744073709551615, 72057594037927937, 144115188075856163,
          360287970189639680, 9151595913498591232, 9223372036854775809, 18374686483966590975]
    names = ['id', 'ctor', 'pair_snd', 'pair_fst', 'maybe', 'recursion', 'fork', 'array_get', 'array_swap',
             'closure', 'pick', 'bang']
    return names, [[str(v) for v in vs] for _ in names]


def check(names, want, text):
    got = [g.split() for g in text.strip().strip('"').split('|')[:-1]]
    bad = [n for i, n in enumerate(names) if i >= len(got) or got[i] != want[i]]
    return len(got) == len(want) and not bad, f'{len(want)} groups, ' + (
        f'mismatches: {" ".join(bad)}' if bad or len(got) != len(want) else '0 mismatches')


if __name__ == '__main__':
    names, want = {'f64': f64, 'u64ops': u64ops, 'u64': u64}[sys.argv[1]]()
    ok, msg = check(names, want, open(sys.argv[2]).read())
    print(msg)
    sys.exit(0 if ok else 1)
