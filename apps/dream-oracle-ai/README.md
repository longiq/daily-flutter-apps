# Dream Oracle AI 🌙

Nhật ký giấc mơ có **AI diễn giải biểu tượng**: ghi lại giấc mơ, để AI (Ollama local) hoặc từ điển biểu tượng offline giải mã ý nghĩa, theo dõi xu hướng cảm xúc theo thời gian.

## Tính năng
- **Nhật ký giấc mơ**: ghi tiêu đề, nội dung, mood emoji, tags; tìm kiếm theo từ khóa.
- **Diễn giải AI**: gọi Ollama local để phân tích giấc mơ, giọng văn ấm áp, gợi mở.
- **Offline fallback**: nếu không có Ollama, tự động dùng từ điển ~40 biểu tượng giấc mơ phổ biến (rắn, nước, bay, rơi, răng, nhà...) để tổng hợp diễn giải — app luôn dùng được kể cả không mạng.
- **Từ điển giấc mơ**: duyệt/tìm kiếm toàn bộ biểu tượng theo từ khóa hoặc chủ đề.
- **Thống kê**: streak ngày ghi nhật ký liên tiếp, cảm xúc phổ biến, biểu tượng thường gặp.
- **Cài đặt**: cấu hình host/model Ollama, kiểm tra kết nối, bật chế độ offline cưỡng bức, dark mode.
- 6 màn hình: Trang chủ, Ghi giấc mơ, Diễn giải, Từ điển giấc mơ, Thống kê, Cài đặt.

## Đối tượng & kiếm tiền
- **Đối tượng:** người thích tự khám phá bản thân, quan tâm tâm linh/giấc mơ, thói quen viết nhật ký.
- **Kiếm tiền:** free với giới hạn diễn giải AI/ngày (fallback offline luôn miễn phí); Premium IAP mở khoá diễn giải AI không giới hạn + thống kê nâng cao; banner ads ở màn Trang chủ/Từ điển.

## Cấu trúc
```
lib/
├── main.dart
├── models/      (dream_entry, symbol_meaning)
├── data/        (symbol_dictionary_data — ~40 biểu tượng)
├── services/    (dream_repository, ollama_service, offline_interpreter)
├── providers/   (dream_provider, settings_provider)
├── screens/     (home, edit_dream, interpretation, symbol_dictionary, stats, settings)
├── widgets/     (dream_card, mood_picker, symbol_chip, empty_state)
└── theme/       (app_theme)
test/            (dream_entry, offline_interpreter, dream_provider, symbol_dictionary_data)
```
State management: **provider**. Lưu dữ liệu: **shared_preferences**. Gọi AI: **http** tới Ollama REST API.

## Cắm Ollama (AI local)
```bash
# Cài: https://ollama.com
ollama pull llama3.2
ollama serve                 # mặc định http://localhost:11434
```
Trên Android emulator, đổi host trong Cài đặt thành `http://10.0.2.2:11434`. Nếu không cắm Ollama, app tự dùng từ điển biểu tượng offline — không cần cấu hình gì thêm.

## Chạy thử (trên Mac mini M4)
```bash
cd ~/ClaudeCreateApp/apps/dream-oracle-ai
flutter create .            # sinh android/ ios/ macos/ web/ lần đầu
flutter pub get
flutter run -d macos        # hoặc -d chrome / -d <iphone-sim>
flutter test
```
> Lưu ý: thư mục `android/ios/web/macos` **chưa** được tạo sẵn — chạy `flutter create .` một lần trong thư mục này để sinh nền tảng.

## ✅ Checklist publish
- [ ] App icon (flutter_launcher_icons) + adaptive icon Android.
- [ ] Splash screen.
- [ ] Screenshots (điện thoại + tablet) cho store.
- [ ] Privacy policy (URL công khai) — bắt buộc vì có lưu nhật ký cá nhân + ads/IAP.
- [ ] Tích hợp ads (google_mobile_ads) + cấu hình AdMob app id.
- [ ] Tích hợp in_app_purchase cho gói Premium.
- [ ] Android: `key.properties` + signing config, build `flutter build appbundle`.
- [ ] iOS: signing trong Xcode, `flutter build ipa`, upload qua Transporter.
- [ ] Điền `version`/`build number` trong `pubspec.yaml`.
- [ ] Mô tả store + từ khoá (ASO): "giải mộng", "dream interpretation", "nhật ký giấc mơ".
