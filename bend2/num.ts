// Num
// ===
// The natives of Base's 64-bit numbers (num.bend): a C template over u64
// and a JS one over BigInt per def, and the runtime helpers they call.

type Op = { C: string; JS: string };

const CMPS = "is_eq:==:=== is_ne:!=:!== is_lt:< is_le:<= is_gt:> is_ge:>=";

// One template per "name:C-op:JS-op" entry, $o its operator.
function ops(pre: string, names: string, C: string, JS: string):
  Record<string, Op> {
  return Object.fromEntries(names.split(" ").map((p) => {
    const [k, o = k, jo = o] = p.split(":");
    return [pre + k, { C: C.replaceAll("$o", o), JS: JS.replaceAll("$o", jo) }];
  }));
}

export const OPS: Record<string, Op> = {
  ...ops("u64_", "add:+ sub:- mul:* and:& or:| xor:^", "($0 $o $1)",
    "BigInt.asUintN(64, $0 $o $1)"),
  ...ops("u64_", CMPS, "((u64)($0 $o $1))", "($0 $o $1)"),
  ...ops("u64_", "inc:+ shl:<< shr:>>", "($0 $o 1)",
    "BigInt.asUintN(64, $0 $o 1n)"),
  ...ops("u64_", "shln:<< shrn:>>", "($1 >= 64 ? 0 : $0 $o $1)",
    "($1 >= 64n ? 0n : BigInt.asUintN(64, $0 $o $1))"),
  ...Object.fromEntries([
    ["div", "($1 == 0 ? 0 : $0 / $1)", "($1 === 0n ? 0n : $0 / $1)"],
    ["mod", "($1 == 0 ? $0 : $0 % $1)", "($1 === 0n ? $0 : $0 % $1)"],
    ["shr_jam", "($1 >= 64 ? (u64)($0 != 0)"
      + " : $0 >> $1 | (u64)(($0 & ((1ull << $1) - 1)) != 0))",
    "($1 >= 64n ? BigInt($0 !== 0n)"
      + " : $0 >> $1 | BigInt(($0 & ((1n << $1) - 1n)) !== 0n))"],
    ["not", "(~$0)", "BigInt.asUintN(64, ~$0)"],
    ["cmp", "(($0 > $1) + ($0 >= $1))", "cmp_new($0, $1)"],
    ["join", "((u64)(u32)$1 << 32 | (u32)$0)",
      "(BigInt($1) << 32n | BigInt($0))"],
    ["lo", "((u64)(u32)$0)", "Number(BigInt.asUintN(32, $0))"],
    ["hi", "($0 >> 32)", "Number($0 >> 32n)"],
    ["clz", "u64_clz($0)", "(64 - $0.toString(2).length + ($0 === 0n))"],
    ["mul_hi", "u64_mul_hi($0, $1)", "(($0 * $1) >> 64n)"],
  ].map(([k, C, JS]) => ["u64_" + k, { C, JS }])),
  ...ops("f64_", "bits from_bits", "$0", "$0"),
  ...ops("f64_", "add:+ sub:- mul:* div:/", "f64_of(f64_num($0) $o f64_num($1))",
    "f64_of(f64_num($0) $o f64_num($1))"),
  ...ops("f64_", CMPS, "((u64)(f64_num($0) $o f64_num($1)))",
    "(f64_num($0) $o f64_num($1))"),
  f64_sqrt: {
    C:  "f64_of(sqrt(f64_num($0)))",
    JS: "f64_of(Math.sqrt(f64_num($0)))",
  },
};

export const C = String.raw`
// F64 is IEEE bits, a NaN result the canonical one; Metal has no double
// (N7), so reading one there fail-stops
#ifdef __METAL_VERSION__
#define f64_num(x) (err_post(e.mem, ERR_FIDS), 0.0f)
#define f64_of(x)  0ull
#else
INLINE double f64_num(u64 x) {
  union { u64 u; double f; } p = { x };
  return p.f;
}

INLINE u64 f64_of(double x) {
  union { double f; u64 u; } p = { x };
  return x != x ? 0x7FF8000000000000ull : p.u;
}
#endif

INLINE u64 u64_clz(u64 x) {
  u64 n = 64;
  for (; x != 0; x >>= 1) {
    n -= 1;
  }
  return n;
}

// the high half of a 128-bit product, over 32-bit partial products
INLINE u64 u64_mul_hi(u64 a, u64 b) {
  u64 lo = (a & 0xFFFFFFFF) * (b & 0xFFFFFFFF);
  u64 m1 = (a >> 32) * (b & 0xFFFFFFFF) + (lo >> 32);
  u64 m2 = (a & 0xFFFFFFFF) * (b >> 32) + (m1 & 0xFFFFFFFF);
  return (a >> 32) * (b >> 32) + (m1 >> 32) + (m2 >> 32);
}

`.slice(1);

export const JS = String.raw`
const F64_VIEW = new DataView(new ArrayBuffer(8));

function f64_num(x) {
  F64_VIEW.setBigUint64(0, x);
  return F64_VIEW.getFloat64(0);
}

function f64_of(x) {
  F64_VIEW.setFloat64(0, x);
  return x !== x ? 0x7FF8000000000000n : F64_VIEW.getBigUint64(0);
}

// the shortest decimal that reads back, as term_show spells it
function f64_show(b) {
  const x = f64_num(b);
  let s = "nan";
  for (let p = 1; x === x && p <= 17 && Number(s) !== x; p += 1) {
    s = String(Number(x.toExponential(p - 1)));
  }
  return (Object.is(x, -0) ? "-0" : s).replace("Infinity", "inf");
}

function word_to_u64(w) {
  let x = 0n;
  for (let i = 0n; w.$ === "WCon"; i++) {
    x |= BigInt(w.head) << i;
    w = w.tail;
  }
  return x;
}

function u64_to_word(x) {
  let w = {$: "WNil"};
  for (let i = 63n; i >= 0n; i--) {
    w = {$: "WCon", head: (x >> i & 1n) === 1n, tail: w};
  }
  return w;
}

`.slice(1);
