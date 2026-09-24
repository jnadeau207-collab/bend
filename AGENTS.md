# AGENTS

Bend is a dependently typed, affine language that checks in one linear bidirectional pass and runs massively parallel on CPU threads and GPUs.

## Mandate

> **make one line execute the full power and prowess of 1,000 lines**

Short code is necessary. Every wasted character, duplicate branch, needless abstraction, wrapper, compatibility layer, comment that restates code, and repeated algorithm is a defect. Prefer the smallest program that completely expresses the invariant.

Compression never excuses fragility. The shortest code wins only when it is also the clearest correct code, preserves semantics, handles adversarial cases, and survives the gates. Do not golf away types, proofs, error handling, numerical contracts, or tests. Remove machinery; do not hide it.

Before adding code, ask whether an existing primitive, type, algebraic law, generated form, or one general operation can delete the need for it. A beautiful general rule is better than a thousand special cases.

## Agentic coding

Agents may edit every project file when the task requires it, including `bend2/bend.ts`. The old blanket prohibition on editing the human-written language/checker is removed. Changes to parser, theory, checker, erasure, or language semantics require focused regression tests that prove the intended contract and preserve old behavior unless the change explicitly revises it.

Do not route around a proper language change in `comp.ts` merely to avoid touching `bend.ts`.

Make the smallest coherent diff. No speculative frameworks, placeholder layers, duplicated implementations, dead compatibility paths, or "future-proof" scaffolding. If ten lines can become one without weakening correctness, make it one. If one line obscures an invariant that five lines prove, use five.

A failing invariant is fixed at its source. Never weaken a theorem, expected value, precision rule, gate, or adversarial test to make code pass.

## Repository map

- `bend2/bend.ts`: parser, theory, checker.
- `bend2/comp.ts`: compiler plus C/Metal/CUDA/JS runtimes and emitters.
- `bend2/main.ts`: CLI and build driver.
- `bend2/base.bend`: base library.
- `bend2/bend.lean`: mechanized core.
- `bend2/effs/`: IO effect sources per backend; related effects may share one.
- `bend2/docs/F64_CONTRACT.md`: numeric semantics.
- `bend2/docs/F64_IMPLEMENTATION.md`: numeric execution order.
- `tests/`: executable contracts; every regression belongs here.
- `gates/test.ts`: all tests.
- `gates/perf.ts`: pinned performance.
- `gates/repo.ts`: repository shape and size.
- `gates/ping.ts`: installer, compiled bend, its daily version check, release.
- `gates/_run.ts`: all four gates; the 30 s cap is law.

## Numerical rule

Source representation and optimized runtime representation must be observationally identical. Raw numeric words are not tagged runtime Terms. Storage preserves bits; arithmetic applies the numeric contract. A backend may optimize an operation only if the optimized result has the same observable semantics.

For the F64 program, read `bend2/docs/F64_CONTRACT.md` before coding and execute `bend2/docs/F64_IMPLEMENTATION.md` in order.
