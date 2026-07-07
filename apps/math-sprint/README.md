# Math Sprint ⚡

Game **giải toán tốc độ**: trả lời càng nhiều phép tính đúng trong thời gian giới hạn càng tốt. Chuỗi đúng liên tiếp tạo **combo** để nhân điểm thưởng. Hoàn toàn **offline**, không cần mạng.

## Tính năng
- 4 chế độ chơi: Khởi động (cộng dễ), Hỗn hợp, Thử thách (đủ 4 phép, số lớn), Bảng cửu chương (nhân/chia 45s).
- Hệ thống **combo** + điểm thưởng theo độ khó.
- **6 thành tích** mở khoá dần (lưu bền vững).
- Màn **Thống kê**: điểm cao, số ván, câu đúng, combo tốt nhất + lịch sử 20 ván gần nhất.
- **Dark mode** và bật/tắt âm thanh (lưu bằng `shared_preferences`).
- 6 màn hình: Trang chủ, Chọn chế độ, Chơi, Kết quả, Thống kê, Thành tích, Cài đặt.

## Đối tượng & kiếm tiền
- **Đối tượng:** học sinh tiểu học/THCS luyện tính nhẩm, người lớn rèn phản xạ.
- **Kiếm tiền:** banner ads ở màn kết quả; rewarded ad "x2 điểm" hoặc "thêm 15s"; IAP gói Premium gỡ ads + mở thêm chế độ/skin số.

## Cấu trúc
```
lib/
├── main.dart
├── models/      (game_mode, question, game_result, achievement)
├── services/    (question_generator, storage_service, achievement_service)
├── providers/   (settings_provider, game_provider)
├── screens/     (home, mode_select, game, result, stats, achievements, settings)
├── widgets/     (answer_button, combo_indicator, stat_card)
└── theme/       (app_theme)
test/            (question_generator, achievement, game_result)
```
State management: **provider**. Lưu dữ liệu: **shared_preferences**.

## Chạy thử (trên Mac mini M4)
```bash
cd ~/ClaudeCreateApp/apps/math-sprint
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
- [ ] Privacy policy (URL công khai) — bắt buộc nếu có ads/IAP.
- [ ] Tích hợp ads (google_mobile_ads) + cấu hình AdMob app id.
- [ ] Android: `key.properties` + signing config, build `flutter build appbundle`.
- [ ] iOS: signing trong Xcode, `flutter build ipa`, upload qua Transporter.
- [ ] Điền `version`/`build number` trong `pubspec.yaml`.
- [ ] Mô tả store + từ khoá (ASO).
