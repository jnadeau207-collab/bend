# FORK: jnadeau207-collab/bend

This checkout is the U64/F64 fork of bendlang/bend. Upstream merged our
emission speedup (#1056) and our Base simplifications (as #1153), and
closed the U64 and F64 PRs (#1057, #1058): the maintainers will add both
themselves (WONTFIX.txt's SOON list) and merge no PR for them. Until they
do, this fork is the only source of U64 and F64.

## 1. Never run `bend update`

The installed `bend` (WSL `~/.bend/bin/bend`, also exposed to PowerShell
as `bend`) is compiled from this fork, not from a release. `bend update`
pipes bend-lang.com/install.sh into sh, which replaces it with the latest
upstream release and silently drops U64 and F64. There is no prompt and
no undo; the only recovery is rebuilding below.

The install is built from the BendCAD pin, tag `numeric/2026-10-05`
(`a4d17ace`); `~/.bend/FORK` records it. Rebuild from that tag (the
layout install.sh uses: bin/bend beside bend2/ and guide/):

    git checkout numeric/2026-10-05
    bun build --compile --target=bun-linux-x64 ./bend2/main.ts \
      --outfile ~/.bend/bin/bend
    rm -rf ~/.bend/bend2 ~/.bend/guide
    cp -r bend2 guide ~/.bend/

## 2. Branches and tags

- `main`: upstream plus U64, F64 and the F64 min/max fix, replayed (and
  force-pushed) when upstream moves. Each old main is kept as a tag
  `archive/main-*`.
- `numeric-on-upstream`: the BendCAD pin branch. Upstream `653e391b`
  plus U64, F64, `bend2/docs/F64_*.md`, `conformance/` and its receipts,
  the min/max fix and the host scheduler. Each BendCAD pin is a tag
  `numeric/<date>` on it, with its conformance receipt in
  `conformance/receipts/`; pin tags are never deleted.
- `numeric`: the earlier pin branch, kept as history behind tag
  `numeric/2026-09-29`.

A pin moves only after `conformance/run.sh` passes at D=20 on every lane
and BendCAD's laws, suites and oracles pass on the new build.

When upstream ships U64 and F64: install bend from upstream
(`curl -fsSL https://bend-lang.com/install.sh | sh`), move BendCAD's pin
to an upstream release, and delete this file and the FORK section in
AGENTS.md.
