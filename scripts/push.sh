#!/usr/bin/env bash
# Đẩy toàn bộ thay đổi (app mới, sửa code...) lên GitHub trong 1 lệnh.
# Dùng:  ./scripts/push.sh
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

git add -A
if git diff --cached --quiet; then
  echo "Không có thay đổi để push."
  exit 0
fi

git commit -m "Auto: cập nhật app $(date +%F)"
git push
echo "✅ Đã push lên GitHub — CI sẽ tự chạy."
