# Bend 2 64-bit Numeric Contract

**Status:** as built. Each clause says whether it holds and what checks it. `conformance/` runs the checks on every lane a machine has; `conformance/receipts/` keeps the runs. The draft this replaces (baseline `0b7e2b1`, 2026-09-18) is in tag `archive/main-2026-09-24`.

## 1. First principle

The checker and every compiled backend observe the same datatype. Raw storage is authoritative bits; construction, destruction, copying, arrays, closures, scheduling and device transport never canonicalize; a machine float exists only inside an arithmetic operation, and an arithmetic NaN result may be canonical. Never weaken a theorem to match an optimizer.

- **U64 and F64:** holds. An F64 is stored as the bits of a U64, never as a JS Number.
- **F32:** does not hold on JS. Upstream closed `bendlang/bend#797` as not planned: optimized JS stores an F32 as a Number, which can quiet a signaling NaN. Nothing below covers F32.

## 2. Raw words are not Terms

A runtime cell holds 48-bit immediates and reads bit 63 (`RFC_BIT`) and the all-ones word (`TERM_HOLE`) as tags, so a 64-bit word is two `U32` halves, low first, in every layout: registers, node fields, arrays, closure captures, task frames and fork results. Only a native joins the halves into one `u64`, and it splits its result back.

**Holds:** `tests/base/u64_transport.bend`; `conformance/probe_u64.bend` moves 2^63, 2^64-1 and tag-shaped words through twelve paths.

## 3. U64

`type U64 is Data: U64{lo: U32, hi: U32}`. The draft's `U64{data: Word(64n)}` cannot sit in the runtime's cells; the defs compute on `Word(64n)` through `U64.word` and `U64.of`.

- add, sub and mul wrap modulo 2^64; bitwise operations are exact;
- shifts by 0..63 shift, and by 64 or more give 0;
- division by zero is 0 and modulo by zero is the dividend, as for U32;
- `U64.to_nat` fail-stops past 2^48-1, as `Nat.add` does; no other operation goes through Nat;
- a literal is `NUMBER "u64"`; past 2^64-1, with a fraction or with an `n` suffix it is a parse error.

Every operation is a Base def over `Word(64n)` with a native on every lane: C and CUDA `u64`, Metal `ulong`, JS `BigInt`. `U64.add_comm` is proved in Base.

**Holds:** `tests/base/u64_ops.bend`, the differential's U64 groups, `conformance/probe_u64ops.bend`.

## 4. I64

Not built.

## 5. F64 representation

`type F64 is Data: F64{bits: U64}`. For every U64 `x`, `F64.bits(F64{x}) == x`.

**Holds:** the checker proves it (`tests/proof/f64_literal_unfolds.bend`), and every lane moves signed zeros, subnormals, infinities, quiet and signaling NaNs, payloads and all ones untouched (`tests/base/f64_transport.bend`, `conformance/probe_f64.bend`).

A literal is `(NUMBER | F32's) "f64"`: its decimal rounded to nearest by the host's parser. One that rounds to infinity is a parse error.

## 6. Arithmetic

add, sub, mul, div, sqrt, fma, min, max, neg, abs, the six predicates and the conversions.

Round to nearest, ties to even. Subnormals are kept, never flushed to zero. No reassociation: `F64.fma(a, b, c)` rounds once, and `a * b + c` twice. A NaN result is `0x7FF8000000000000`; neg, abs and moves keep a payload. A finite nonzero over a signed zero is a signed infinity; 0/0 and inf/inf are NaN.

Every operation is a Base def that computes binary64 in integer arithmetic over U64. Where the lane has a double, a native runs instead (comp.ts's `SOFT` table), and the two agree to the bit.

**Holds:** the differential's F64 groups on JS, C, CUDA, CUDA and the CPU cores running the defs, and the interpreter; `tests/base/f64_ops.bend`.

## 7. Comparisons

An ordered comparison with a NaN is false, and `is_ne` with a NaN is true. +0 and -0 compare equal; `F64.bits` tells them apart. No total order is built.

**Holds:** the differential's `cmp`, `cmpz` and `minmax` groups.

## 8. Conversions

`F64.to_u64`, `F64.to_u32` and `F64.to_f32` answer 0 (`to_f32`: the quiet NaN) for NaN, negatives and out-of-range values, as F32 and U32 do. `U64.to_f64`, `U32.to_f64` and `F32.to_f64` round to nearest, exactly where the value fits. No conversion goes through F32 or Nat.

**Holds:** the differential's conversion groups.

## 9. Backends

- **C and the CPU cores:** a native `double` per operation, one statement each, without fast-math.
- **JavaScript:** a Number or a BigInt exists only inside an operation; fma is exact (a BigInt product and one rounding).
- **CUDA:** a native `double` per operation; NVRTC compiles with `--fmad=false`, so a multiply never fuses into an add.
- **Metal:** no double. Every operation runs its Base def as integer arithmetic over `ulong` on the device, with no CPU callback and no F32 pair.

**Not run:** no Metal device has executed it. `conformance/`'s `cuda-defs` lane runs the same defs on CUDA, and its `metal` check finds no double left when the emitted C is read as a Metal compile reads it.

## 10. Device claims

A build is not evidence of execution.

- `--gpu off` runs every `!` on the CPU cores.
- `--gpu on`, or a size such as `--gpu 4GB`, requires the device: a program with `!` calls refuses to run when no device opens, every `!` pass is then a device launch, and a device fault stops the run. A macOS build's device is Metal and a Linux build's is CUDA, so a required run names its backend by the platform it was built on.
- With no flag, a program uses the device when one opens and otherwise runs `!` on the CPU cores without a note.
- **Not built:** a line in the output that names the backend that ran.

## 11. Constant folding

The checker folds F64 through the same Base defs that Metal runs: `1.0f64 + 2.0f64` reduces to `3.0f64` with no host float. A literal is parsed by the host's `Number`, which is not a fifth backend: `conformance/`'s `text` check compares 37 hard decimals (halfway cases, the subnormal boundary, digit strings past 17 digits) with Python's correctly rounded `float`.

## 12. Show and read

`F64.show` is the shortest decimal that reads back, in JavaScript's format (`nan`, `inf`, `-0`, `1e+21`, `1e-7`). `F64.read` parses a decimal, `inf` or `nan` to the nearest double, and answers `None` for anything else. Both are laws with a native on each host lane (C `snprintf`/`strtod`, JS `Number`); the interpreter has neither.

**Holds:** `text` on JS and C.

## 13. Scope

Bend owns scalar representation, core arithmetic, conversions, backend execution and generic conformance. BendCAD owns CAD numerics: vectors, stable hypot, predicates, intervals, large-angle trigonometry, curve and surface numerics, roots and topology.
