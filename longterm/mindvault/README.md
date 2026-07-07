# MindVault 🧠🔒

Ghi chú thông minh có **AI hỏi-đáp trên chính ghi chú của bạn** (mini-RAG), chạy bằng **Ollama local** → dữ liệu không rời máy, riêng tư 100%.

> Đây là **app dài hạn**, phát triển qua nhiều ngày theo roadmap trong `../ONGOING.md`.

- **Loại:** Productivity + AI
- **Trạng thái:** Milestone 5 xong — UX polish (theme, animation, icon, splash), tiếp theo là Monetization

## Tính năng hiện có (M1-M5)
- Thêm / sửa / xóa ghi chú, có tag
- Lưu local bằng `shared_preferences` (mở lại app vẫn còn)
- Tìm kiếm theo tiêu đề / nội dung / tag
- **Tóm tắt AI** một ghi chú qua Ollama local, tự fallback tóm tắt offline (trích câu quan trọng) nếu không có Ollama
- **Hỏi vault của bạn**: mini-RAG local — chia ghi chú thành đoạn, tìm đoạn liên quan bằng term-frequency + cosine similarity, rồi Ollama (hoặc offline) trả lời kèm nguồn
- Auto-tag: gợi ý tag qua Ollama hoặc từ điển offline, lọc theo nhiều tag cùng lúc
- Màn Cài đặt: đổi giao diện sáng/tối/theo hệ thống, cấu hình Ollama, kiểm tra kết nối
- State management bằng `provider`
- Animation: chuyển màn mờ dần + trượt nhẹ, danh sách xuất hiện so le, chip/card phản hồi khi nhấn
- App icon + splash screen đã cấu hình (`flutter_launcher_icons` + `flutter_native_splash`) — cần chạy generate trên Mac mini

## Cấu trúc
```
lib/
  main.dart                       # khởi tạo + đăng ký provider + themeMode
  models/note.dart                # model ghi chú + JSON + search
  models/chunk.dart                # NoteChunk/ScoredChunk cho mini-RAG
  services/note_repository.dart   # lưu local (ChangeNotifier)
  services/ai_settings.dart       # cấu hình Ollama (host/model/bật-tắt)
  services/theme_settings.dart    # sáng/tối/theo hệ thống, lưu local
  services/ollama_service.dart    # gọi Ollama REST API, không throw ra UI
  services/offline_ai.dart        # fallback tóm tắt/trả lời khi không có Ollama
  services/rag_service.dart       # mini-RAG: chunk + cosine similarity + ask()
  services/auto_tagger.dart       # gợi ý tag (Ollama + offline từ điển)
  services/text_utils.dart        # tách câu/từ dùng chung (không cần regex lookbehind)
  utils/page_transitions.dart     # FadeSlideRoute/fadeSlideTo dùng chung
  screens/home_screen.dart        # danh sách + tìm kiếm + lọc tag + nút Hỏi vault/Cài đặt
  screens/edit_screen.dart        # thêm/sửa + nút Tóm tắt AI + Gợi ý tag
  screens/ask_screen.dart         # màn "Hỏi vault của bạn"
  screens/settings_screen.dart    # đổi giao diện + cài đặt Ollama + test kết nối
  widgets/note_card.dart, tag_filter_bar.dart, tag_chip_input.dart, fade_slide_in.dart
assets/icon/, assets/splash/       # icon + splash (chưa generate — xem bên dưới)
test/note_test.dart, rag_service_test.dart, offline_ai_test.dart,
     ollama_service_test.dart, text_utils_test.dart, auto_tagger_test.dart,
     note_repository_test.dart, theme_settings_test.dart, fade_slide_in_test.dart
```

## Chạy & test (trên Mac mini M4)
```bash
flutter pub get
flutter test                 # chạy unit test
flutter run -d macos         # hoặc -d chrome / -d <iphone-sim>
flutter analyze
# generate app icon + splash từ assets/icon, assets/splash (chạy 1 lần, hoặc lại khi đổi ảnh):
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Cách kiếm tiền
| Kênh | Mô tả |
|------|-------|
| Free | Ghi chú + tìm kiếm cơ bản |
| Premium (IAP) | AI hỏi-đáp RAG, auto-tag, đồng bộ |
| Ads | Banner cho bản free |

## Roadmap kế tiếp
Xem `../ONGOING.md`. Milestone tiếp theo: **M6 — Monetization**.

## ✅ Checklist publish (khi app chín)
- [ ] `flutter analyze` + `flutter test` sạch
- [x] App icon + splash cấu hình xong (`flutter_launcher_icons` + `flutter_native_splash`) — nhớ chạy generate trên Mac mini
- [ ] Screenshots điện thoại + tablet
- [ ] Privacy policy (bắt buộc nếu có ads/IAP)
- [ ] Cấu hình IAP + AdMob
- [ ] Android: `flutter build appbundle` → Play Console
- [ ] iOS: Archive trong Xcode → Transporter
- [ ] Signing: keystore (Android) / provisioning (iOS)
