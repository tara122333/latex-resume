#!/usr/bin/env bash
# Build the resume PDF from main.tex with Tectonic (XeTeX engine; pdflatex can't
# load the fontspec setup in main.tex).
#
# Usage: ./build.sh [input.tex] [output.pdf]
#   defaults: main.tex -> Tara_Chand_Kumawat_Software_Engineer.pdf
set -euo pipefail

cd "$(dirname "$0")"

TEX="${1:-main.tex}"
PDF="${2:-Tara_Chand_Kumawat_Software_Engineer.pdf}"
EXPECTED_PAGES=2

TECTONIC="$(command -v tectonic || echo /opt/homebrew/bin/tectonic)"
if [[ ! -x "$TECTONIC" ]]; then
  echo "error: tectonic not found (install with: brew install tectonic)" >&2
  exit 1
fi
if [[ ! -f "$TEX" ]]; then
  echo "error: $TEX not found" >&2
  exit 1
fi

# Compile into a temp dir so a failed build never touches the existing PDF.
BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

"$TECTONIC" --chatter minimal -o "$BUILD_DIR" "$TEX"
BUILT="$BUILD_DIR/$(basename "${TEX%.tex}").pdf"

if command -v pdfinfo >/dev/null; then
  PAGES="$(pdfinfo "$BUILT" | awk '/^Pages:/ {print $2}')"
  if [[ "$PAGES" != "$EXPECTED_PAGES" ]]; then
    echo "warning: PDF has $PAGES pages (expected $EXPECTED_PAGES)" >&2
  fi
else
  PAGES="?"
fi

cp "$BUILT" "$PDF"
echo "Built $PDF ($PAGES pages)"
