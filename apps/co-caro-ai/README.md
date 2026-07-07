# Cờ Caro AI ⚫⚪

Game **Cờ Caro (Gomoku)** cổ điển: xếp 5 quân liên tiếp để thắng. Chơi **2 người trên cùng máy** hoặc **đấu với AI** (3 độ khó). Hoàn toàn **offline**, không cần mạng.

## Tính năng
- 2 chế độ: **2 người chơi** hoặc **đấu với máy** (AI heuristic: chặn/ăn nước thắng ngay, đánh giá pattern theo 4 hướng, độ khó Khó có nhìn trước 1 nước).
- 3 cỡ bàn: 9x9, 13x13, 15x15.
- Highlight đường thắng, hoàn tác nước đi (undo), chơi lại nhanh.
- Màn **Thống kê**: tổng ván, thắng/thua/hoà, tỉ lệ thắng, lịch sử 20 ván gần nhất.
- **Dark mode** + bật/tắt âm thanh, lưu cài đặt & lịch sử bằng `shared_preferences`.
- 6 màn hình: Trang chủ, Chọn chế độ, Chơi, Thống kê, Cài đặt, Hướng dẫn chơi.

## Đối tượng & kiếm tiền
- **Đối tượng:** người chơi cờ caro giải trí mọi lứa tuổi, người muốn luyện chiến thuật với AI.
- **Kiếm tiền:** banner ads ở trang chủ/màn chơi; rewarded ad (vd "hoàn tác thêm 1 lần"); IAP Premium gỡ quảng cáo (đã có nút demo ở màn Cài đặt).

## Cấu trúc
```
lib/
├── main.dart
├── models/      (enums, move, match_record, app_settings)
├── services/    (win_checker, ai_service, storage_service)
├── providers/   (settings_provider, stats_provider, game_provider)
├── screens/     (home, mode_select, game, stats, settings, how_to_play)
├── widgets/     (board_widget, cell_widget, stat_card)
└── theme/       (app_theme)
test/            (win_checker, ai_service, game_provider, match_record)
```
State management: **provider**. Lưu dữ liệu: **shared_preferences**.

AI: heuristic pattern-scoring theo 4 hướng (không phải minimax đầy đủ vì bàn quá lớn), luôn ưu tiên ăn/chặn nước thắng ngay lập tức; độ khó "Khó" có thêm bước nhìn trước 1 nước để tránh mở đường cho đối thủ.

## Chạy thử (trên Mac mini M4)
```bash
cd ~/ClaudeCreateApp/apps/co-caro-ai
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
- [ ] Tích hợp ads thật (google_mobile_ads) + cấu hình AdMob app id.
- [ ] Tích hợp IAP thật (in_app_purchase) thay cho nút "Mua" demo ở Cài đặt.
- [ ] Android: `key.properties` + signing config, build `flutter build appbundle`.
- [ ] iOS: signing trong Xcode, `flutter build ipa`, upload qua Transporter.
- [ ] Điền `version`/`build number` trong `pubspec.yaml`.
- [ ] Mô tả store + từ khoá (ASO).
