# Bend 2 F64 Implementation Program

`F64_CONTRACT.md` is the semantic authority. This is the board as built: each phase, where it stands, and what shows it. The board this replaces is in tag `archive/main-2026-09-24`.

| Phase | Status | Evidence |
|---|---|---|
| P0A reproduce #797 | Upstream closed #797 as not planned | |
| P0B raw-bit F32 on JS | Not built: F32 is outside the contract | |
| P0C adversarial F32 transport | Not built | |
| P0D raw `w64` apart from Term | Done: two `U32` halves in every layout | `tests/base/u64_transport.bend`, `probe_u64` |
| N0 semantics fixed | Done: the contract | |
| N1 U64 transport | Done | `tests/base/u64_transport.bend`, `probe_u64` |
| N2 U64 primitives | Done: every op a `Word(64n)` def, with a native per lane | `tests/base/u64_ops.bend`, `probe_u64ops`, the differential's U64 groups |
| N3 F64 raw value | Done | `tests/proof/f64_literal_unfolds.bend`, `tests/base/f64_transport.bend`, `probe_f64` |
| N4 software binary64 core | Done, fma included | the differential on `cuda-defs`, `c-defs` and the interpreter |
| N5 C and JS integration | Done: a native where it is exact | the differential on `js` and `c` |
| N6 strict backend identity | `--gpu on` requires the device and a fault stops the run; no output names the backend | contract §10 |
| N7 Metal | Built, never run on a device | the `cuda-defs` lane, the `metal` check |
| N8 CUDA | Done | the differential and the `!` tests on `cuda` |
| N9 literals, show and read | Done: `u64` and `f64` literals, shortest show, correctly rounded read | `text`, `tests/printer`, `tests/parse` |
| N10 broad qualification | `conformance/`: 2^20 cases per group on every compiled lane, 2^2 on the interpreter | `conformance/receipts/` |

## Upstream

`bendlang/bend` #1057 (U64) and #1058 (F64) carry the language; #1056 (emission) and #1059 (Base helpers) are independent. This branch adds only these documents and `conformance/` to fork main: its `bend2/` tree is the one the receipts name.

## Handoff to BendCAD

BendCAD's gate asks eight things of a pinned commit. On this branch:

1. **#797 fixed:** no, and upstream will not fix it. F64 is immune by construction; F32 must stay out of authoritative geometry.
2. **F32/F64 bit-authoritative on JS:** F64 yes, F32 no (the same).
3. **Raw `w64` apart from Term:** yes.
4. **Arbitrary U64 transport:** yes.
5. **Exact F64 bits:** yes, proved by the checker.
6. **Qualified host arithmetic:** yes, per the receipt.
7. **Strict backend identity:** a required run (`--gpu on` or a size) cannot fall back; nothing reports which backend ran.
8. **Metal execution:** not run.

CAD-specific trigonometry, robust hypot, intervals, exact and adaptive predicates and geometry numerics live in BendCAD.
