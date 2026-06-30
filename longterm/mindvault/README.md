# MindVault 🧠🔒

Ghi chú thông minh có **AI hỏi-đáp trên chính ghi chú của bạn** (mini-RAG), chạy bằng **Ollama local** → dữ liệu không rời máy, riêng tư 100%.

> Đây là **app dài hạn**, phát triển qua nhiều ngày theo roadmap trong `../ONGOING.md`.

- **Loại:** Productivity + AI
- **Trạng thái:** Milestone 1 (nền tảng) — chạy được offline, chưa có AI

## Tính năng hiện có (M1)
- Thêm / sửa / xóa ghi chú, có tag
- Lưu local bằng `shared_preferences` (mở lại app vẫn còn)
- Tìm kiếm theo tiêu đề / nội dung / tag
- State management bằng `provider`
- Dark mode tự động

## Cấu trúc
```
lib/
  main.dart              # khởi tạo + provider
  models/note.dart       # model + JSON + search
  services/note_repository.dart  # lưu local (ChangeNotifier)
  screens/home_screen.dart       # danh sách + tìm kiếm
  screens/edit_screen.dart       # thêm/sửa
  widgets/note_card.dart
test/note_test.dart      # unit test model
```

## Chạy & test (trên Mac mini M4)
```bash
flutter pub get
flutter test                 # chạy unit test
flutter run -d macos         # hoặc -d chrome / -d <iphone-sim>
flutter analyze
```

## Cách kiếm tiền
| Kênh | Mô tả |
|------|-------|
| Free | Ghi chú + tìm kiếm cơ bản |
| Premium (IAP) | AI hỏi-đáp RAG, auto-tag, đồng bộ |
| Ads | Banner cho bản free |

## Roadmap kế tiếp
Xem `../ONGOING.md`. Milestone tiếp theo: **M2 — tích hợp Ollama** (tóm tắt ghi chú, có offline fallback).

## ✅ Checklist publish (khi app chín)
- [ ] `flutter analyze` + `flutter test` sạch
- [ ] App icon + splash (`flutter_launcher_icons`)
- [ ] Screenshots điện thoại + tablet
- [ ] Privacy policy (bắt buộc nếu có ads/IAP)
- [ ] Cấu hình IAP + AdMob
- [ ] Android: `flutter build appbundle` → Play Console
- [ ] iOS: Archive trong Xcode → Transporter
- [ ] Signing: keystore (Android) / provisioning (iOS)
