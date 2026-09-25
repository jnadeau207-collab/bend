#!/bin/bash
set -u
C=$(cd "$(dirname "$0")" && pwd)
R=$(dirname "$C")
D=${D:-16}
K=${CUDA_HOME:-$HOME/cuda/12.9}
G="LD_LIBRARY_PATH=/usr/lib/wsl/lib:$K/lib64"
export PATH="$HOME/.bun/bin:$PATH:/usr/lib/wsl/lib" PYTHONDONTWRITEBYTECODE=1
mkdir -p "${OUT:-/tmp/conformance}" && cd "${OUT:-/tmp/conformance}" || exit 1

cap() {
  if command -v systemd-run > /dev/null; then
    systemd-run --user --scope -q -p MemoryMax=6G -p MemorySwapMax=0 timeout "$@"
  else
    timeout "$@"
  fi
}

build() {
  case $1 in
    js) cap 600 bun "$R/bend2/main.ts" "$2.bend" -o "$2.js" ;;
    c) cap 600 env -u CUDA_HOME bun "$R/bend2/main.ts" "$2.bend" -o "$2.cpu" ;;
    cuda) cap 900 sh "$C/cuda.sh" "$2.bend" "$2.gpu_native" ;;
    cuda-defs) cap 900 env FLIP=1 sh "$C/cuda.sh" "$2.bend" "$2.gpu_defs" ;;
    c-defs) cap 900 env FLIP=1 sh "$C/cuda.sh" "$2.bend" "$2.cpu_defs" ;;
    interp) true ;;
  esac > "$2.$1.build" 2>&1
}

run() {
  case $1 in
    js) cap 900 bun "$2.js" ;;
    c) cap 900 "./$2.cpu" --gpu off ;;
    cuda) cap 900 env "$G" "./$2.gpu_native" --gpu 4GB ;;
    cuda-defs) cap 900 env "$G" "./$2.gpu_defs" --gpu 4GB ;;
    c-defs) cap 900 env "$G" "./$2.cpu_defs" --gpu off ;;
    interp) cap 900 bun "$R/bend2/main.ts" "$2.bend" ;;
  esac
}

go() {
  rm -f "$2.$1.out"
  if build "$1" "$2"; then
    run "$1" "$2" > "$2.$1.out" 2>&1
    e=$?
    [ $e != 0 ] && echo "exit $e" >> "$2.$1.out"
  else
    echo "build failed" > "$2.$1.out"
  fi
  sed -i 's/[[:blank:]]*$//' "$2.$1.out"
}

ident() {
  git -C "$R" diff --quiet HEAD -- bend2 || { echo "bend2 differs from HEAD: commit it first"; exit 1; }
  python3 "$C/diff.py" "$D" "d$D.bend" > "d$D.exp"
  python3 "$C/diff.py" 2 d2.bend flat > d2.exp
  python3 "$C/text.py" write text.bend
  cp "$C"/probe_*.bend .
  echo "code       bend2 tree $(git -C "$R" rev-parse HEAD:bend2), at commit $(git -C "$R" rev-parse HEAD)"
  echo "date       $(date -u +%Y-%m-%dT%H:%MZ)"
  echo "host       $(uname -sr), $(lscpu | sed -n 's/^Model name: *//p')"
  echo "toolchain  bun $(bun --version), clang $(clang -dumpversion), python $(python3 -c 'import sys, numpy; print(sys.version.split()[0] + ", numpy " + numpy.__version__)')"
  echo "device     $(nvidia-smi --query-gpu=name,driver_version --format=csv,noheader | head -1 | sed 's/, / driver /'), NVRTC $(ls "$K"/lib64/libnvrtc.so.*.*.* | head -1 | sed 's/.*\.so\.//')"
  echo "vectors    2^$D cases per differential group, 22 groups, the splitmix64 stream from index 0 (no seed); the interpreter at 2^2"
  echo "programs   $(sha256sum "d$D.bend" d2.bend text.bend probe_*.bend | awk '{printf "%s%s %s", (NR > 1 ? ", " : ""), $2, substr($1, 1, 16)}')"
}

skip() {
  case $1 in
    cuda|cuda-defs) ! grep -q '!(' "$2" ;;
    interp) [ "$2" = probe_f64.bend ] ;;
    *) false ;;
  esac
}

lane() {
  l=$1
  d=$([ "$l" = interp ] && echo 2 || echo "$D")
  echo "lane $l"
  s=$(date +%s%N)
  go "$l" "d$d"
  echo "  diff     2^$d x 22 groups: $(python3 "$C/diff.py" check "d$d.exp" "d$d.$l.out") ($(( ($(date +%s%N) - s) / 1000000000 )) s)"
  case $l in
    cuda-defs|c-defs)
      FLIP=1 sh "$C/cuda.sh" "d$d.bend" "d$d.defs.c" > /dev/null 2>&1
      echo "  defs     $(grep -c '#if 0' "d$d.defs.c") soft-native call sites of the diff program compiled as their Base defs" ;;
  esac
  for p in f64 u64ops u64; do
    skip "$l" "probe_$p.bend" && continue
    go "$l" "probe_$p"
    echo "  probe    $p: $(python3 "$C/probes.py" "$p" "probe_$p.$l.out")"
  done
  case $l in
    js|c)
      go "$l" text
      echo "  text     $(python3 "$C/text.py" check "text.$l.out")" ;;
    cuda|cuda-defs|c-defs)
      for t in "$R"/tests/base/u64_*.bend "$R"/tests/base/f64_*.bend; do
        skip "$l" "$t" && continue
        n=$(basename "$t" .bend)
        grep '^#|' "$t" | cut -c3- | sed 's/[[:blank:]]*$//' > "$n.want"
        cp "$t" "$n.bend"
        go "$l" "$n"
        cmp -s "$n.want" "$n.$l.out" && r=pass || r=FAIL
        echo "  test     $n: $r"
      done ;;
  esac
}

metal() {
  echo "metal"
  rm -f ./*.metal.c
  for p in "d$D" "$R"/tests/base/u64_*.bend "$R"/tests/base/f64_*.bend; do
    b=$(basename "$p" .bend)
    [ -f "$b.bend" ] || cp "$p" "$b.bend"
    bun "$R/bend2/main.ts" "$b.bend" -o "$b.metal.c" > /dev/null 2>&1 || echo "  $b: emit failed"
  done
  python3 "$C/metal.py" *.metal.c | sed 's/^/  /'
}

case ${1:-} in
  ident) ident ;;
  metal) metal ;;
  js|c|cuda|cuda-defs|c-defs|interp) lane "$1" ;;
  all) ident && for l in js c cuda cuda-defs c-defs interp; do lane $l; done && metal ;;
  *) echo "usage: [D=16] [OUT=dir] run.sh ident|js|c|cuda|cuda-defs|c-defs|interp|metal|all"; exit 2 ;;
esac
