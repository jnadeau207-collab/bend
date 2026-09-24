// Num
// ===
// The natives of Base's 64-bit numbers (num.bend): a C template over u64
// and a JS one over BigInt per def, and the runtime helpers they call.

type Op = { C: string; JS: string };

const F64_VIEW = new DataView(new ArrayBuffer(8));

export function f64_from_bits(n: bigint): number {
  F64_VIEW.setBigUint64(0, n);
  return F64_VIEW.getFloat64(0);
}

// a decimal's bits; null past the largest finite (Number parses
// correctly rounded, as the f32 literal beside it already relies on)
export function f64_read(t: string): bigint | null {
  const v = Number(t);
  if (!isFinite(v)) {
    return null;
  }
  F64_VIEW.setFloat64(0, v);
  return F64_VIEW.getBigUint64(0);
}


export const CMPS = "is_eq:==:=== is_ne:!=:!== is_lt:< is_le:<= is_gt:> is_ge:>=";

// One template per "name:C-op:JS-op" entry, $o its operator.
export function ops(pre: string, names: string, C: string, JS: string):
  Record<string, Op> {
  return Object.fromEntries(names.split(" ").map((p) => {
    const [k, o = k, jo = o] = p.split(":");
    return [pre + k, { C: C.replaceAll("$o", o), JS: JS.replaceAll("$o", jo) }];
  }));
}

// The natives no lane without a double runs: the compiler spins their
// def on such a lane and inlines them elsewhere.
export const SOFT = new Set(("f64_add f64_sub f64_mul f64_div f64_is_eq"
  + " f64_is_ne f64_is_lt f64_is_le f64_is_gt f64_is_ge f64_sqrt").split(" "));

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
  f64_show: {
    C:    "f64_show(e, $0)",
    call: true,
    JS:   "f64_show($0)",
  },
  f64_read: {
    C:    "f64_read(e, $0)",
    call: true,
    JS:   "f64_read($0)",
  },
};

export const C = String.raw`
// F64 is IEEE bits, a NaN result the canonical one; a lane without a
// double has no use of these (its arithmetic spins the def instead)
#ifndef __METAL_VERSION__
INLINE double f64_num(u64 x) {
  union { u64 u; double f; } p = { x };
  return p.f;
}

INLINE u64 f64_of(double x) {
  union { double f; u64 u; } p = { x };
  return x != x ? 0x7FF8000000000000ull : p.u;
}
#endif

#if DEVICE
#define f64_show(e, x) (err_post(e.mem, ERR_FIDS), 0)
#define f64_read(e, s) (err_post(e.mem, ERR_FIDS), 0)
#else
static Term f64_show(Env e, Term x);
static Term f64_read(Env e, Term s);
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

export const IO = String.raw`
static Term f64_show(Env e, Term x) {
  char buf[40];
  return io_str(e, buf, f32_text(buf, f64_num(x), 17));
}

static Term f64_read(Env e, Term s) {
  u64 n = 0;
  char* text = io_cstr(e, s, &n);
  char* end;
  u64 v = f64_of(strtod(text, &end));
  Term out = n > 0 && (u64)(end - text) == n && strpbrk(text, "xX(") == NULL
    ? io_box(e, CID_SOME, io_node(e, CID_F64, (u32)v, v >> 32))
    : term_pak(CID_NONE, 0);
  free(text);
  return out;
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

function f64_read(s) {
  const re = /^\s*[+-]?((\d+\.?\d*|\.\d+)(e[+-]?\d+)?|inf(inity)?|nan)$/i;
  const v = Number(s.replace(/inf\w*/i, "Infinity"));
  return re.test(s) ? {$: "Some", value: f64_of(v)} : {$: "None"};
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
