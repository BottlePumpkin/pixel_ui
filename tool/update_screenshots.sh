#!/usr/bin/env bash
# tool/update_screenshots.sh
# Regenerate pub.dev screenshot goldens and sync them to doc/screenshots/.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "→ Regenerating goldens..."
flutter test --update-goldens test/screenshots/screenshots_test.dart

expected=(01_hero 02_corners 03_shadows 04_buttons 05_texture 06_pixel_grid)

echo "→ Verifying goldens exist..."
for name in "${expected[@]}"; do
  src="test/screenshots/goldens/${name}.png"
  if [[ ! -f "$src" ]]; then
    echo "ERROR: missing golden: $src" >&2
    exit 1
  fi
done

echo "→ Copying to doc/screenshots/..."
mkdir -p doc/screenshots
for name in "${expected[@]}"; do
  cp "test/screenshots/goldens/${name}.png" "doc/screenshots/${name}.png"
done

echo "→ Done. doc/screenshots/ contents:"
du -h doc/screenshots/*.png
