#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Kicked-Ball Simulation - Web (Vercel) build betigi
# ---------------------------------------------------------------------------
# NE YAPAR:
#   1. localization/strings.csv -> scripts/StringsBaked.gd (metin yedegi)
#   2. Godot "Web" preset'ini public/ klasorune disa aktarir
#
# KULLANIM:
#   ./build.sh                      # godot komutu PATH'te ise
#   GODOT=/yol/Godot_v4.6-stable_linux.x86_64 ./build.sh
#
# GEREKENLER:
#   - Godot 4.6 (proje 4.6 ile yazildi)
#   - Ayni surumun Web disa aktarma sablonlari (Editor -> Manage Export
#     Templates -> Download and Install)
#
# Build bittikten sonra:  git add public && git commit && git push
# Vercel push'u gorunce public/ klasorunu oldugu gibi yayinlar (build yok).
# ---------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT/godot-src"
OUT="$ROOT/public"
GODOT="${GODOT:-godot}"

if ! command -v "$GODOT" >/dev/null 2>&1 && [ ! -x "$GODOT" ]; then
  echo "HATA: Godot bulunamadi. GODOT=/yol/godot ./build.sh seklinde calistirin." >&2
  exit 1
fi

echo "==> Godot surumu"
"$GODOT" --version

echo "==> Kaynaklar iceri aktariliyor (ilk calistirmada uzun surer)"
"$GODOT" --headless --path "$SRC" --import

echo "==> Metinler pisiriliyor (strings.csv -> StringsBaked.gd)"
"$GODOT" --headless --path "$SRC" --script tools/bake_strings.gd

echo "==> Bassiz duman testi"
"$GODOT" --headless --path "$SRC" --script tools/smoke_test.gd

echo "==> Web disa aktarimi -> public/"
mkdir -p "$OUT"
"$GODOT" --headless --path "$SRC" --export-release "Web" "$OUT/index.html"

echo "==> Bitti. Uretilen dosyalar:"
ls -la "$OUT"
