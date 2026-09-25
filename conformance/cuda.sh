#!/bin/sh
set -e
R=$(cd "$(dirname "$0")/.." && pwd)
export PATH="$HOME/.bun/bin:$PATH" CUDA_HOME="${CUDA_HOME:-$HOME/cuda/12.9}"
export LIBRARY_PATH=/usr/lib/wsl/lib LD_LIBRARY_PATH="/usr/lib/wsl/lib:$CUDA_HOME/lib64"
H=$(mktemp -d)
trap 'rm -rf "$H"' EXIT
cp -r "$R/bend2" "$H/"
C="$H/bend2/comp.ts"
sed -i 's/^  return managed != 0$/  return (managed | 1) != 0/' "$C"
grep -q '^  return (managed | 1) != 0$' "$C"
if [ -n "${FLIP:-}" ]; then
  grep -q 'file_push(fl, "#ifndef __METAL_VERSION__")' "$C"
  sed -i 's/file_push(fl, "#ifndef __METAL_VERSION__")/file_push(fl, "#if 0")/' "$C"
  if grep -q 'file_push(fl, "#ifndef __METAL_VERSION__")' "$C"; then exit 1; fi
fi
bun "$H/bend2/main.ts" "$1" -o "$2"
