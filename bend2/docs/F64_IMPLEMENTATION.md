# Bend 2 F64 Implementation Program

This is the sprint board. `F64_CONTRACT.md` is the semantic authority.

Do not start by writing F64 arithmetic.

## P0 — make compiled values mean what the checker proves

### P0A — reproduce #797

Add the signaling-NaN program from `bendlang/bend#797` as a regression without weakening its theorem or expected raw bits.

Record the present split: checker accepts; C preserves; optimized JS changes the signaling-NaN payload.

**Exit:** the defect is locally reproducible.

### P0B — raw-bit F32 on JS

Make optimized JS F32 storage an exact U32 payload.

Construction/destruction copy bits. Actual F32 operations explicitly:

```text
bits -> Number -> operation -> bits
```

Update arithmetic, comparisons, conversions, math operations, show/read, constants, and main-value printing coherently. Do not special-case the one failing vector.

**Exit:** #797 is green with the theorem untouched, and every existing F32 compile test remains green.

### P0C — adversarial F32 transport

Permanently test +0, -0, qNaN, sNaN, payloads, infinities, subnormals, arrays, constructors, closures, and forks.

**Exit:** source constructor/destructor identity equals compiled JS identity.

### P0D — separate raw w64 from Term

**Done by layout:** a 64-bit word is two `w32` halves wherever it is stored (contract §2); `tests/run/u64_transport.bend` probes it.

Probe values containing tag bits, `RFC_BIT`, `TERM_HOLE`, and all ones through constructors, arrays, closure capture/return, scheduler frames, and fork results.

**Exit:** no raw word is interpreted as runtime metadata.

## N0 — freeze only the next semantics

The numeric contract already answers U64 division/modulo by zero, wide shifts, F64 NaN storage/arithmetic, default rounding, invalid unsigned conversion, and backend representation. Amend the contract before code if a new semantic question appears. Do not scatter policy through emitters.

## N1 — U64 transport, zero arithmetic ambition

Add `U64{Word(64n)}`, width-generic exact Word helpers, W64 layout, exact JS BigInt/raw storage, and C `u64`.

Transport at least:

```text
0
1
2^32
2^48
2^53-1
2^53
2^53+1
2^63
2^64-1
TERM_HOLE pattern
RFC_BIT pattern
tag-looking patterns
```

through scalar return, mixed constructors, tuple, Maybe, recursive data, arrays/swaps, closures, recursion, forks, static constants, C and JS.

Device transport is a separate qualification gate: missing hardware does not block P0/N1 host progress.

**Exit:** C and JS preserve every tested 64-bit pattern exactly. **Done:** `tests/run/u64_transport.bend`.

## N2 — only the U64 primitives F64 needs

Implement the smallest integer substrate required by software binary64:

- bitwise ops and defined shifts;
- compare;
- clz;
- add-with-carry;
- sub-with-borrow;
- wide multiply;
- shift-right-with-jam.

Do not build a giant integer library first.

**Exit:** differential tests pass on host lanes; device lanes follow when available. **Host done:** `tests/run/u64_ops.bend` against exact integers. Base defines each op once over `Word(n)` (U32 and U64 share one long division); natives are C `u64` and JS BigInt.

## N3 — F64 raw value

Add `F64{Word(64n)}`, exact `from_bits/bits`, classification, sign operations, and conversions needed to exercise representation.

No add/sub/mul yet.

**Exit:** every important IEEE class and arbitrary NaN payload round-trips through C and JS. **Host done:** `tests/run/f64_bits.bend` (bits, class masks, sign ops, exact U32/F32 to F64; JS stores F64 as BigInt bits).

## N4 — software binary64 core

Implement or adapt a compact integer core for:

- add/sub;
- mul;
- div;
- sqrt;
- FMA.

Berkeley SoftFloat is an independent oracle. Metal softfloat projects are licensed prior art, not evidence.

Favor one small semantic core over four backend-specific algorithms.

**Exit:** host software core matches the declared contract on adversarial vectors.

## N5 — C and JS integration

Use native operations only where they exactly implement the contract; otherwise use the software core. Keep raw-bit storage authoritative. Constant folding may not invent host-Number semantics.

**Exit:** compiled Bend C and JS match the core oracle.

## N6 — strict backend identity

Add strict GPU/backend selection before qualification language exists. A requested device that did not execute is failure, not fallback success.

**Exit:** receipts can prove CPU vs Metal vs CUDA execution.

## N7 — Metal

Embed the software core in Bend's generated single translation unit and execute it as Metal integer code over `ulong` payloads.

No F32 pair. No CPU callback. No FTZ. No hidden fallback.

**Exit:** compiled Bend vectors execute on actual Metal and return correct bits.

## N8 — CUDA

Qualify native double and explicit FMA under the same observable contract.

**Exit:** compiled Bend vectors execute on actual CUDA and return correct bits.

## N9 — literals, I/O, serialization

Only after representation/arithmetic is stable:

- explicit U64/F64 literals;
- correctly rounded decimal F64 parsing;
- shortest round-trip display;
- exact little-endian raw serialization.

Editing `bend2/bend.ts` is allowed and expected when the language grammar requires it.

## N10 — broad qualification

Keep the normal gate tiny and adversarial. Large TestFloat/SoftFloat/MPFR/device campaigns are qualification jobs, not excuses to violate the 30 s gate law.

Every receipt names commit, backend, device, toolchain, vector count, seed, generated program identity, and mismatches.

## Stop conditions

Reject any patch that:

- weakens a theorem or expected value;
- stores F64 as JS Number;
- uses Nat as U64;
- passes raw U64 through Term helpers;
- calls F32 pairs "F64";
- hides CPU fallback as Metal;
- folds F64 with unqualified host Number;
- grows a framework before the failing invariant is closed;
- duplicates an algorithm that one general primitive can express.

## Handoff to BendCAD

BendCAD may begin its serious numeric geometry layer only after a pinned Bend commit has:

1. F32 JS representation soundness fixed;
2. arbitrary U64 transport proven;
3. exact F64 bit transport;
4. qualified add/sub/mul/div/sqrt/FMA and conversions on required host lanes;
5. strict backend identity;
6. actual Metal F64 execution qualified.

CAD-specific trig, robust hypot, interval algorithms, exact/adaptive predicates, and geometry numerics live in BendCAD.
