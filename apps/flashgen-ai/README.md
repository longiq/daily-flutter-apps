# FlashGen AI 🃏

Dán ghi chú/bài học → AI tự sinh **flashcard** (câu hỏi + đáp án) để học theo kiểu lật thẻ.
Chạy được **offline** với **Ollama local** (phù hợp môi trường hạn chế mạng nội bộ).

## Điểm độc đáo
- Sinh thẻ bằng AI **local** (Ollama) — không gửi dữ liệu lên cloud, dùng được trong mạng nội bộ.
- Có **fallback offline**: nếu chưa cắm Ollama, app vẫn tạo thẻ cloze đơn giản để không bao giờ "trắng màn hình".
- Lưu deck bằng SharedPreferences — không cần backend, không cần đăng nhập.

## Cách kiếm tiền
| Kênh | Mô tả |
|------|-------|
| Free | Tối đa 5 bộ thẻ, có quảng cáo banner |
| Premium (IAP) | Không giới hạn bộ thẻ, ẩn quảng cáo, xuất thẻ CSV/Anki |
| Rewarded ads | Xem quảng cáo để mở thêm 1 slot deck tạm thời |

> Vị trí gating đã đặt sẵn ở `HomeScreen.freeDeckLimit` và `_showPremiumDialog()`.
> Cắm `in_app_purchase` + `google_mobile_ads` vào đó là xong.

## Lệnh chạy
```bash
flutter pub get
flutter run
```

## Cắm Ollama (AI local)
1. Cài Ollama: https://ollama.com
2. Tải model: `ollama pull llama3.2`
3. Chạy server: `ollama serve` (mặc định `http://localhost:11434`)
4. Cấu hình host trong `lib/ai_service.dart`:
   - iOS simulator / desktop: `http://localhost:11434`
   - **Android emulator**: đổi `baseUrl` thành `http://10.0.2.2:11434`
   - Thiết bị thật: dùng IP máy chạy Ollama, VD `http://192.168.1.10:11434`

> Muốn dùng API cloud (OpenAI/Gemini) thì thay `_callOllama()` bằng request tương ứng và đặt API key qua biến môi trường (đừng hardcode key vào repo).

## Cấu trúc
```
lib/
  main.dart          # App + Home + dialog sinh thẻ (setState)
  models.dart        # Flashcard, Deck + JSON
  ai_service.dart    # Gọi Ollama + fallback offline
  storage.dart       # Lưu/đọc deck (SharedPreferences)
  study_screen.dart  # Màn học: lật thẻ, vuốt qua thẻ
```

## Kiểm tra code
> Môi trường tạo file này **không có** Flutter SDK nên chưa chạy `flutter analyze`.
> Trên máy bạn hãy chạy:
```bash
flutter analyze
flutter test   # nếu thêm test
```

## ✅ Checklist submit store
- [ ] **App icon** đủ kích thước (dùng `flutter_launcher_icons`)
- [ ] **Splash screen** (`flutter_native_splash`)
- [ ] **Screenshots**: Android (phone + tablet), iOS (6.7" + 5.5")
- [ ] **Privacy Policy** URL (bắt buộc — app dùng lưu trữ cục bộ, ghi rõ "không thu thập dữ liệu")
- [ ] **App signing**: Android tạo keystore + `key.properties`; iOS cấu hình signing trong Xcode
- [ ] `applicationId` / `bundleId` riêng (vd `com.longiq.flashgenai`)
- [ ] Tăng `version` trong `pubspec.yaml`
- [ ] Build release:
  - Android: `flutter build appbundle` → file `.aab`
  - iOS: `flutter build ipa` (cần macOS + tài khoản Apple Developer)
- [ ] Điền **Data safety form** (Google Play) / **App Privacy** (App Store)
- [ ] Nếu bật ads: khai báo AdMob app ID + tuân thủ chính sách quảng cáo
- [ ] Phân loại nội dung (content rating)

---
*App được tạo tự động ngày 2026-06-30 bởi tác vụ "daily-flutter-app".*
