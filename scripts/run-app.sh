#!/usr/bin/env bash
# Chạy thử 1 app Flutter trên Chrome (cách nhanh nhất).
# Dùng:  ./scripts/run-app.sh apps/app-2026-06-29-odd-color-tap
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="${1:-}"

if [ -z "$APP" ]; then
  echo "Chọn app để chạy:"
  select d in $(cd "$ROOT" && ls -d apps/*/ longterm/*/ 2>/dev/null); do
    APP="$d"; break
  done
fi

cd "$ROOT/$APP"
echo "▶ Đang chạy: $APP"
# Sinh thư mục nền tảng nếu chưa có (repo chỉ chứa code thuần)
[ -d web ] || flutter create --platforms=android,ios,web,macos .
flutter pub get
flutter run -d chrome
