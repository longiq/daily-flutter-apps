# Kích hoạt GitHub Actions CI (làm 1 lần)

CI tự động: mỗi lần bạn `git push`, GitHub sẽ tự **test + build APK + build web** cho tất cả app, rồi cho tải file về ở tab **Actions → Artifacts**. Bạn không phải làm gì thêm ngoài push code.

## Bước 1 — Tạo repo GitHub
Vào github.com → New repository → đặt tên (vd `daily-flutter-apps`) → **Private** → Create. ĐỪNG thêm README/gitignore (đã có sẵn ở đây).

## Bước 2 — Đẩy code lên (chạy trong Terminal, 1 lần)
```bash
cd ~/ClaudeCreateApp
git init
git add .
git commit -m "Khởi tạo: apps + CI"
git branch -M main
git remote add origin https://github.com/longiq/daily-flutter-apps.git
git push -u origin main
```

## Bước 3 — Xem kết quả
- Vào repo → tab **Actions** → workflow "Flutter CI" tự chạy.
- Xong → mục **Artifacts** có `<tên-app>-apk` và `<tên-app>-web` để tải về.
- File `.apk` cài thẳng lên điện thoại Android để test thật.

## Sau này
Mỗi ngày app mới sinh ra trong `apps/` hoặc `longterm/`. Bạn chỉ cần:
```bash
cd ~/ClaudeCreateApp
git add . && git commit -m "app mới" && git push
```
CI tự lo phần test + build. Việc DUY NHẤT bạn làm thủ công là **chạy thử app thật** (`./scripts/run-app.sh`) để mắt thường kiểm tra UX.

## Ghi chú
- CI **chỉ build app vừa thay đổi** trong lần push (tiết kiệm phút). Sửa file chung `.github/`/`.gitignore` hoặc bấm "Run workflow" tay → build tất cả.
- Free tier: repo Private = 2.000 phút Linux/tháng; repo Public = không giới hạn.
- CI build **Android (APK) + Web**. iOS cần máy ảo macOS (runner trả phí) → để sau khi chuẩn bị publish.
- `flutter analyze` chỉ cảnh báo, không làm fail build.
- Repo chỉ lưu code thuần; thư mục `android/ios/web` do CI tự sinh (`flutter create`) nên không cần commit (đã để trong `.gitignore`).

## ⚠️ Lưu ý mạng công ty
CI push chỉ làm được ở NHÀ (mạng tự do). Ở công ty mạng nội bộ chặn GitHub → không push được, chỉ code/đọc offline.
