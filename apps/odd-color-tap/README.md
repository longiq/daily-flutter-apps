# Odd Color Tap 🎨

Game casual: tìm và chạm vào ô có **màu khác biệt** trong lưới trước khi hết giờ. Càng lên level, lưới càng to và màu càng giống nhau → càng khó.

- **Thể loại:** Casual / reflex
- **Đối tượng:** Mọi lứa tuổi, chơi giết thời gian
- **Ngày tạo:** 2026-06-29

## Cách kiếm tiền
| Kênh | Cách làm |
|------|----------|
| Banner ad | Hiện banner dưới màn hình (google_mobile_ads) |
| Interstitial ad | Hiện quảng cáo toàn màn hình mỗi lần Game Over |
| Rewarded ad | Xem quảng cáo để "hồi sinh" +10 giây |
| IAP "Remove Ads" | Gói 0.99$ gỡ toàn bộ quảng cáo |

## Chạy thử
```bash
flutter pub get
flutter run        # chọn thiết bị Android/iOS/Chrome
```

## Trạng thái code
- Game **chạy được ngay**, không cần API hay key.
- Chưa tích hợp quảng cáo (để dependency tối thiểu). Xem checklist bên dưới để thêm.
- Điểm cao (best) lưu trong RAM. Muốn lưu vĩnh viễn → thêm `shared_preferences`.

## ✅ Checklist publish lên store
- [ ] Chạy `flutter analyze` (không lỗi)
- [ ] Thêm `google_mobile_ads` + cấu hình AdMob App ID
- [ ] Thêm `shared_preferences` lưu điểm cao
- [ ] Tạo **app icon** (`flutter_launcher_icons`)
- [ ] Chụp **screenshots** (điện thoại + tablet)
- [ ] Viết **Privacy Policy** (bắt buộc nếu có ads) + host 1 URL
- [ ] **Android:** `flutter build appbundle` → upload `.aab` lên Play Console
- [ ] **iOS:** mở `ios/Runner.xcworkspace` → Archive → upload qua Xcode/Transporter
- [ ] Điền store listing (mô tả, category = Games, content rating)
- [ ] Ký số (signing): Android keystore / iOS provisioning profile

## Mở rộng nhanh (nếu muốn)
- Thêm âm thanh tap (package `audioplayers`)
- Chế độ "Zen" không giới hạn thời gian
- Bảng xếp hạng online (Firebase / Game Center)
