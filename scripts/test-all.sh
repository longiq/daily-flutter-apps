#!/usr/bin/env bash
# Chạy unit test cho TẤT CẢ app có thư mục test/.
# Dùng:  ./scripts/test-all.sh
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

for app in "$ROOT"/apps/*/ "$ROOT"/longterm/*/; do
  [ -d "$app/test" ] || continue
  echo "──────────────────────────────"
  echo "🧪 Test: $(basename "$app")"
  ( cd "$app" && flutter pub get >/dev/null && flutter test ) || FAIL=1
done

echo "──────────────────────────────"
[ "$FAIL" -eq 0 ] && echo "✅ Tất cả test PASS" || echo "❌ Có test FAIL"
exit $FAIL
