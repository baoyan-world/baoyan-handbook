#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
  echo "usage: scripts/build-release.sh vX.Y.Z" >&2
  exit 2
fi
VERSION=$1
case "$VERSION" in
  v[0-9]*.[0-9]*.[0-9]*) ;;
  *) echo "version must look like v1.2.3" >&2; exit 2 ;;
esac
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEX_SRC="$ROOT/tex"
OUT_DIR="$ROOT/books/baoyan/$VERSION"
OUT_PDF="$OUT_DIR/中国保研（推免）全流程知识手册-$VERSION.pdf"
if [ -e "$OUT_DIR" ]; then
  echo "refusing to overwrite existing version directory: $OUT_DIR" >&2
  exit 1
fi
BUILD_DIR=$(mktemp -d)
cleanup() { status=$?; if [ "$status" -eq 0 ]; then rm -rf "$BUILD_DIR"; else echo "build logs kept at $BUILD_DIR" >&2; fi; }
trap cleanup EXIT HUP INT TERM
cp -R "$TEX_SRC/." "$BUILD_DIR/"
cd "$BUILD_DIR"
run_xelatex() {
  xelatex -interaction=nonstopmode -halt-on-error main.tex > "pass$1.log" 2>&1 || {
    echo "xelatex pass $1 failed; see $BUILD_DIR/pass$1.log" >&2
    grep -n '^!' "pass$1.log" | head -20 >&2 || true
    exit 1
  }
}
run_indexes() {
  for name in stage theme inst; do
    if [ -f "$name.idx" ]; then makeindex -q "$name.idx" -o "$name.ind"; fi
  done
}
run_xelatex 1
run_indexes
run_xelatex 2
run_indexes
run_xelatex 3
run_xelatex 4
mkdir -p "$OUT_DIR"
cp main.pdf "$OUT_PDF"
pdfinfo "$OUT_PDF" | grep -E '^(Pages|File size):'
sha256sum "$OUT_PDF"
