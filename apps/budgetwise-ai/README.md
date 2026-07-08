# BudgetWise AI

Ứng dụng quản lý thu chi cá nhân: ghi giao dịch thu/chi theo danh mục, đặt
ngân sách hằng tháng, và nhận nhận xét/gợi ý tiết kiệm — cả bằng quy tắc
offline lẫn AI (Cloud AI qua proxy, hoặc Ollama local).

## Tính năng

- **Tổng quan theo tháng:** số dư, tổng thu, tổng chi, biểu đồ chi tiêu theo
  danh mục, 5 giao dịch gần nhất. Chuyển qua lại giữa các tháng.
- **Giao dịch:** thêm/sửa/xóa (vuốt để xóa), tìm theo ghi chú, lọc theo
  loại (thu/chi) và danh mục.
- **Ngân sách:** đặt hạn mức chi tiêu mỗi tháng cho từng danh mục, thanh
  tiến trình cảnh báo khi sắp/đã vượt hạn mức.
- **AI phân tích (tab "AI"):** luôn có nhận xét nhanh dựa trên quy tắc
  (offline, miễn phí không giới hạn) + tùy chọn phân tích chuyên sâu hơn
  bằng AI (thử Cloud AI qua proxy trước, rồi Ollama local — giới hạn 3
  lượt/tháng bản free, không giới hạn nếu bật Premium mô phỏng trong Cài
  đặt).
- **Cài đặt:** chế độ tối, cấu hình Cloud AI (proxy URL/key) và Ollama
  (địa chỉ/model), nút kiểm tra kết nối cho từng bên, bật/tắt Premium (mô
  phỏng mua hàng), xóa toàn bộ dữ liệu.
- Dữ liệu giao dịch/ngân sách lưu hoàn toàn cục bộ bằng `shared_preferences`
  — chỉ nội dung tóm tắt chi tiêu được gửi đi khi bạn bấm "Phân tích ngay",
  tới proxy AI (mặc định) hoặc Ollama local tùy cấu hình.

## Kiếm tiền

- **Free:** đầy đủ tính năng ghi chép + ngân sách + nhận xét quy tắc, giới
  hạn 3 lượt phân tích AI chuyên sâu/tháng.
- **Premium (IAP):** phân tích AI không giới hạn + gỡ quảng cáo.
- **Ads:** banner ở bản free (chưa tích hợp SDK thật — cần cấu hình AdMob ở
  giai đoạn publish).

## Cấu trúc

```
lib/
  main.dart                  điểm khởi động, MultiProvider + theme
  models/                    Category, Transaction, Budget
  providers/                 TransactionProvider, SettingsProvider
  services/                  repository (shared_preferences), CategoryData,
                              CloudAiService, OllamaService, OfflineInsights
  screens/                   RootShell (bottom nav) + 6 màn hình
  widgets/                   TransactionTile, CategoryPicker,
                              BudgetProgressBar, SpendingBarChart, EmptyState
  theme/                     AppTheme (light/dark, tông xanh lá)
test/                        4 file test (model, provider, insights, category data)
```

## Chạy thử

```bash
cd ~/ClaudeCreateApp/apps/budgetwise-ai
flutter pub get
flutter run -d chrome     # hoặc -d macos / -d <iphone-sim>
```

## Chạy test

```bash
flutter test
```

## Cấu hình Cloud AI

Mặc định app đã trỏ sẵn tới `ai-proxy` dùng chung (xem `PROJECT_NOTES.md` ở
gốc repo) — không cần cấu hình gì để "Phân tích ngay" hoạt động ngay cả khi
máy không chạy Ollama. Đổi trong **Cài đặt → Cloud AI (proxy)**:
- **Proxy URL**: mặc định `https://ai-proxy-2f7q.onrender.com`.
- **Proxy key**: khớp `PROXY_SECRET` của proxy đang trỏ tới.
- Nút "Kiểm tra kết nối" để xác nhận proxy còn sống.

Tự deploy proxy riêng thì xem `backend/ai-proxy/README.md`, rồi đổi 2 giá
trị trên; hoặc tắt Cloud AI để chỉ dùng Ollama/offline.

## Dùng AI local (tùy chọn — chỉ cần khi dev/test hoặc muốn dùng model riêng)

```bash
ollama pull llama3.2
ollama serve
```
Trên Android emulator, đổi địa chỉ Ollama trong Cài đặt thành
`http://10.0.2.2:11434`. Nếu tắt Cloud AI và không kết nối được Ollama, app
vẫn hoạt động đầy đủ nhờ `OfflineInsights` (quy tắc nội bộ, không cần mạng).

## Checklist trước khi publish

- [ ] App icon (`flutter_launcher_icons`) + splash screen.
- [ ] Screenshots cho store listing (điện thoại + tablet nếu có).
- [ ] Privacy policy (app lưu dữ liệu giao dịch local; nêu rõ việc gửi tóm
      tắt chi tiêu tới proxy AI/Gemini hoặc Ollama local khi dùng tính năng
      phân tích AI).
- [ ] Tích hợp AdMob thật (banner free) + `in_app_purchase` thật cho Premium
      (hiện đang mô phỏng bằng switch trong Cài đặt).
- [ ] Ký app (signing) cho Android (`keystore`) và iOS (certificates/profile
      qua Xcode/App Store Connect).
- [ ] Build bản phát hành:
      `flutter build appbundle` (Android) và `flutter build ipa` (iOS).
- [ ] Sinh thư mục nền tảng trước khi build thật:
      `flutter create --platforms=android,ios,web,macos .`
