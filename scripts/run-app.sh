#!/usr/bin/env bash
# Chạy thử 1 app Flutter trên nền tảng tùy chọn (web / macOS / iOS simulator / Android).
# Dùng:  ./scripts/run-app.sh                      -> chọn app + nền tảng từ menu
#        ./scripts/run-app.sh apps/odd-color-tap   -> chọn nền tảng từ menu
#        ./scripts/run-app.sh apps/odd-color-tap ios
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="${1:-}"
PLATFORM="${2:-}"

# 1) Chọn app
if [ -z "$APP" ]; then
  echo "Chọn app:"
  select d in $(cd "$ROOT" && ls -d apps/*/ longterm/*/ 2>/dev/null); do
    APP="$d"; break
  done
fi

# 2) Chọn nền tảng
if [ -z "$PLATFORM" ]; then
  echo "Chạy trên nền tảng nào?"
  select p in "chrome (web - nhanh nhất)" "ios (iPhone simulator)" "macos (cửa sổ trên Mac)" "android (emulator/máy thật)"; do
    PLATFORM="${p%% *}"; break
  done
fi

cd "$ROOT/$APP"
echo "▶ App: $APP  |  Nền tảng: $PLATFORM"

# Sinh thư mục nền tảng nếu chưa có (repo chỉ chứa code thuần)
if [ ! -d web ] || [ ! -d ios ]; then
  flutter create --platforms=android,ios,web,macos .
  rm -f test/widget_test.dart   # bỏ test mẫu do flutter create sinh (tham chiếu MyApp)
fi

flutter pub get

case "$PLATFORM" in
  ios)
    open -a Simulator || true   # bật iPhone simulator
    sleep 3
    flutter run -d iPhone       # khớp simulator có tên chứa "iPhone"
    ;;
  macos)  flutter run -d macos ;;
  android) flutter run -d android ;;
  *)      flutter run -d chrome ;;
esac
