# Bend 2 64-bit Numeric Contract

**Baseline:** `jnadeau207-collab/bend@0b7e2b11c1054f5d0f4eb955cadb47997ef1115d`  
**Status:** contract for implementation; not a claim that U64/F64 is complete.

## 1. First principle

The checker and every compiled backend must observe the same datatype.

Upstream issue `bendlang/bend#797` proves this is false for one current path: source-level F32 construction/destruction preserves a signaling-NaN Word, while optimized JS storage converts through Number and quiets it.

Therefore:

- raw storage is authoritative bits;
- construction, destruction, copying, arrays, closures, scheduling, and device transport do not canonicalize floating values;
- conversion to a machine float occurs only at an arithmetic operation boundary;
- arithmetic may canonicalize a NaN result according to this contract.

Never weaken a theorem to match an optimizer.

## 2. Raw words are not Terms

`w32`, `w64`, and `box` are distinct compiler kinds; a `w64` is a Nat, whose 48-bit cap keeps its tag byte zero.

A 64-bit word type (U64, then F64 and I64) lies as two `w32` halves, low first, in every layout: node fields, arrays (a raw u32 buffer), closure captures, task frames, fork results. Every stored word is below 2^32, so no bit pattern can read as a runtime Term. Only a native joins the halves into one `u64`, and splits its result back.

An arbitrary U64 equal to `TERM_HOLE`, containing `RFC_BIT`, or resembling a tag remains numeric data and never passes through Term tag/reference-count operations.

## 3. U64

`U64{data: Word(64n)}` admits every 64-bit pattern.

- add/sub/mul wrap modulo 2^64;
- bitwise operations are exact;
- left/right shifts by 0..63 shift normally;
- shifts by >=64 return 0;
- division by zero returns 0, matching U32;
- modulo by zero returns the dividend, matching U32;
- conversions never use Nat as the full-width carrier;
- text/literal overflow is rejected rather than wrapped.

## 4. I64

I64 shares the exact 64-bit transport path. Full signed arithmetic is not a prerequisite for initial F64 work.

When implemented:

- representation is two's complement;
- wrapping operations are defined via raw U64 semantics, never C signed-overflow UB;
- checked operations report overflow explicitly;
- exceptional division, including MIN / -1, has one documented result before release.

## 5. F64 representation

`F64{data: Word(64n)}` stores an IEEE-754 binary64 encoding.

For every U64 value `x`:

```text
F64.bits(F64.from_bits(x)) == x
```

This includes:

- +0 and -0;
- every subnormal and normal;
- +/- infinity;
- every quiet NaN;
- every signaling NaN;
- every NaN payload;
- all-ones and runtime-looking bit patterns.

The identity applies to storage and transport, not arithmetic.

## 6. Ordinary F64 arithmetic

Initial core:

- add, sub, mul, div;
- sqrt;
- explicit fused multiply-add;
- comparisons;
- conversions;
- classification and sign operations.

Default rounding is round-to-nearest, ties-to-even. Subnormals are preserved; ordinary F64 never flushes to zero. Reassociation is forbidden. `a*b+c` has two roundings; explicit `fma(a,b,c)` has one.

If an arithmetic result is NaN, ordinary operations return canonical quiet NaN:

```text
0x7ff8000000000000
```

Input NaN payloads remain exact until an arithmetic operation consumes them.

IEEE division semantics apply: finite nonzero divided by signed zero yields signed infinity; 0/0 and infinity/infinity yield canonical qNaN.

## 7. Comparisons

Numeric equality and bit equality are distinct.

- ordinary ordered comparisons follow IEEE behavior;
- any ordered comparison with NaN is false except `is_ne`, which is true;
- +0 and -0 compare numerically equal;
- `F64.bits` distinguishes them;
- total ordering, if added, is a separate API.

## 8. Conversions

No conversion silently travels through F32 or Nat.

Default float-to-unsigned conversion follows Bend's existing F32/U32 failure convention: NaN, infinity, negative values, and out-of-range values return 0. A later checked API may expose richer failure information without changing this ordinary operation.

F32->F64 and F64->F32 are numeric conversions, not bit casts. Raw construction uses `from_bits`.

## 9. Backends

### C/CPU
Stored F64 remains raw bits in two u32 halves. Native `double` may implement qualified arithmetic after explicit unbox/rebox. No fast-math, reassociation, or implicit contraction.

### JavaScript
Stored F32/F64 is raw bits, not Number. F32 may use exact U32; F64 uses exact U64/BigInt or an equivalently exact representation. Number is temporary arithmetic state only.

### CUDA
Native double may implement qualified core arithmetic. Ordinary multiply-add does not contract; explicit FMA may.

### Metal
F64 storage is one `ulong` IEEE binary64 pattern. Arithmetic is GPU-resident integer software binary64. No F32 pair, no CPU callback, no hidden fallback, no normal-only semantics under the general F64 API.

## 10. Device claims

A build is not evidence of execution.

Qualification must support strict selection equivalent to:

- GPU off;
- GPU required;
- Metal required;
- CUDA required;
- backend report.

A Metal-required run fails if Metal did not execute. A CUDA-required run fails if CUDA did not execute.

## 11. Constant folding

Host JavaScript Number is not a fifth F64 backend.

Compile-time arithmetic either uses the same qualified semantics as runtime or is not folded. Literal conversion may use a separately qualified exact parser.

## 12. Scope boundary

Bend owns trustworthy scalar representation, core arithmetic, conversions, backend execution, and generic conformance.

BendCAD owns CAD-specific numerical algorithms: robust vector/matrix math, stable hypot, geometric predicates, interval use, large-angle trig strategy, curve/surface numerics, roots, and topology. Generic improvements may later be upstreamed; they are not prerequisites for closing Bend's representation contract.
