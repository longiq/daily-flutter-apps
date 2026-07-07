# Cài Mac mini M4 để tự build & test app (1 lần)

Sau khi cài xong, bạn chạy bất kỳ app nào trên **web / macOS / iOS simulator** chỉ bằng 1 lệnh.

## 1. Cài công cụ (chạy trong Terminal)

```bash
# Homebrew (nếu chưa có) — xem brew.sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Flutter + CocoaPods (cho iOS)
brew install --cask flutter
brew install cocoapods
```

## 2. Cài Xcode (cho iOS) — bắt buộc nếu muốn build iOS
- Mở **App Store** → cài **Xcode** (vài GB, hơi lâu).
- Sau khi cài, chạy:
```bash
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept
```

## 3. Kiểm tra
```bash
flutter doctor
```
Làm theo gợi ý nếu thấy dấu ✗. Khi các mục Flutter / Xcode / Chrome hiện ✓ là xong.

## 4. Chạy thử app
```bash
cd ~/ClaudeCreateApp
chmod +x scripts/*.sh        # 1 lần

./scripts/run-app.sh                          # chọn app + nền tảng từ menu
./scripts/run-app.sh apps/odd-color-tap ios   # hoặc chỉ định luôn
```
Nền tảng chọn được: `chrome` (nhanh nhất), `ios` (iPhone simulator), `macos`, `android`.

## Quan trọng về iOS
| Mục đích | Cần Apple Developer ($99/năm)? |
|---|---|
| Test trên **iPhone Simulator** | ❌ Không cần — miễn phí |
| Chạy trên **iPhone thật** | ✅ Cần (hoặc tài khoản free giới hạn 7 ngày) |
| Đăng **App Store** | ✅ Cần |

→ Để **test giao diện/logic**, dùng Simulator là đủ, không tốn tiền.

## Ghi chú
- App AI (FlashGen, MindVault): nếu chưa bật Ollama thì tự dùng offline fallback. Muốn test AI thật: `ollama serve` + `ollama pull llama3.2`.
- Script tự chạy `flutter create` để sinh thư mục nền tảng (android/ios/web/macos) — không cần commit, đã có trong `.gitignore`.
- `flutter test` chạy unit test không cần simulator: `./scripts/test-all.sh`.
