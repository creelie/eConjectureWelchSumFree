#!/usr/bin/env bash
# build_paper.sh -- build the paper and its submission files into dist/.
#
#   dist/welch-third-order-sum-free.pdf           the compiled paper
#   dist/welch-third-order-sum-free-tex.zip       main.tex, ready for a journal's LaTeX upload
#   dist/welch-third-order-sum-free-arxiv.tar.gz  main.tex, ready for arXiv
#
# Needs pdflatex with amsart, booktabs and hyperref; zip and tar. The paper has no figures.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PAPER="$ROOT/preprintWelchSumFree"
DIST="$ROOT/dist"
NAME=welch-third-order-sum-free
mkdir -p "$DIST"

latex() { pdflatex -interaction=nonstopmode -halt-on-error "$@" > /dev/null; }

echo "== paper"
cd "$PAPER"
latex main.tex
latex main.tex
latex main.tex
if grep -q "Overfull\|undefined\|Rerun to get" main.log; then
  grep "Overfull\|undefined\|Rerun to get" main.log
  echo "build_paper.sh: fix the warnings above" >&2
  exit 1
fi
cp main.pdf "$DIST/$NAME.pdf"

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

echo "== tex.zip"
mkdir -p "$STAGE/$NAME"
cp main.tex "$STAGE/$NAME/"
( cd "$STAGE/$NAME" && latex main.tex && latex main.tex && rm -f main.aux main.log main.out main.pdf )
rm -f "$DIST/$NAME-tex.zip"
( cd "$STAGE" && zip -qr "$DIST/$NAME-tex.zip" "$NAME" )

echo "== arXiv tarball"
mkdir -p "$STAGE/arxiv"
cp main.tex "$STAGE/arxiv/"
( cd "$STAGE/arxiv" && latex main.tex && latex main.tex && rm -f main.aux main.log main.out main.pdf )
tar -czf "$DIST/$NAME-arxiv.tar.gz" -C "$STAGE/arxiv" .

rm -f main.aux main.log main.out main.pdf
ls -l "$DIST"
