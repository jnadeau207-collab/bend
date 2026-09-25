# Numeric conformance

`bend2/docs/F64_CONTRACT.md` says what U64 and F64 must do. This directory checks it on every lane a machine has, and `receipts/` keeps the runs.

```sh
D=20 conformance/run.sh ident   # the tested tree, host, toolchain, device, and the generated programs
D=20 conformance/run.sh js      # then one lane per call: js c cuda cuda-defs c-defs interp
D=20 conformance/run.sh metal
D=20 conformance/run.sh all     # every step in order
```

`D` sets the differential's size, 2^D cases per group (default 16); `OUT` sets the work directory (default `/tmp/conformance`). Run `ident` first: it writes the programs the lanes run, and it refuses to start when `bend2/` differs from `HEAD`, because a receipt names the tree it tested. Each step prints its part of the receipt.

## Lanes

| Lane | Build | Run |
|---|---|---|
| `js` | `bend x.bend -o x.js` | `bun x.js` |
| `c` | `bend -o` without CUDA | `--gpu off`: every `!` on the CPU cores |
| `cuda` | `cuda.sh` | `--gpu 4GB`: the binary refuses to run without the device, and every `!` pass is a CUDA launch |
| `cuda-defs` | `cuda.sh` with `FLIP=1` | the same, with every F64 soft native compiled as its Base def: Metal's code, on CUDA |
| `c-defs` | `cuda.sh` with `FLIP=1` | `--gpu off`: Metal's code on the CPU cores |
| `interp` | | `bend x.bend` |

`cuda.sh` builds from a copy of `bend2/` with two edits, and fails unless each applies. `gpu_probe` accepts a device without concurrent managed access: WSL2 reports none, and the runtime touches managed memory from the host only between synchronizations. With `FLIP=1`, `emit_fuse` guards each soft native with `#if 0` instead of `#ifndef __METAL_VERSION__`, so every target takes the def. The script is for WSL2 (CUDA at `CUDA_HOME`, default `~/cuda/12.9`); where the device reports concurrent managed access, plain `bend -o` with `CUDA_HOME` set builds the same lane.

## Checks

- **diff** (`diff.py`): 22 groups, each a `!` wave over 2^D cases whose results fold into one checksum per group, against Python. The oracle uses exact rationals for sums, products and fma, numpy's binary64 for quotients and roots, and exact integers for U64. The cases come from a splitmix64 stream whose doubles lean on subnormals, zeros, infinities, NaN payloads and extreme exponents. The groups: add, sub, cancelling sub, mul, div, fma, cancelling fma, sqrt, compares, signed-zero compares, min and max, `to_u64`, `to_u32`, `to_f32`, U64, U32 and F32 to F64, neg and abs, U64 arithmetic, division and modulo, bit operations, and compares with clz. The interpreter runs 2^2 cases.
- **probe** (`probes.py`):
  - `probe_f64.bend` moves 20 hostile bit patterns through identity, a constructor, a pair, a Maybe, an Array, a closure, a generic pick and a `!` call, then through each operation and show.
  - `probe_u64ops.bend` runs 23 U64 operations on 7 edge values.
  - `probe_u64.bend` moves 15 words through 12 paths.

  The `cuda` lanes run only the programs with a `!` call, since only `!` reaches the device. The interpreter skips `probe_f64`, which reaches upstream's bodiless `F32.bits`.
- **text** (`text.py`, `js` and `c`): `F64.show` of 3170 doubles against the shortest round-trip text in JavaScript's format, `F64.read` of each back to its bits, and 37 hard decimals as literals and as reads against Python's correctly rounded `float`. The doubles are every power of two, the specials and 1024 stream values; the decimals include halfway cases, the subnormal boundary and digit strings past 17 digits.
- **test**: the U64 and F64 tests in `tests/base`, those with a `!` call on the `cuda` lanes and all of them on `c-defs`. The test gate runs them on the interpreter, JS and C.
- **defs**: how many soft-native call sites of the differential the `FLIP` build compiles as their Base defs.
- **metal** (`metal.py`): reads each emitted C file's `#if` tree as a Metal compile does. It lists every kept line with `double`, a double helper, `fma(`, `sqrt(`, `__int128` or `__umul64hi`; none may remain. This reads source; it is not a Metal run.

## Receipts

A receipt names the tested `bend2/` tree and commit, the date, host, toolchain and device, the vector counts, the generated programs' hashes, and each check's mismatches. It holds for any commit whose `git rev-parse <commit>:bend2` is the tree it names.
