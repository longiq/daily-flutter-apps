# App dài hạn đang phát triển

> Task `flutter-longterm-project` (T3/5/7) đọc file này để biết app nào đang làm và milestone kế tiếp.

## Project active: MindVault
- **Folder:** `longterm/mindvault/`
- **Mô tả:** Ghi chú thông minh có AI hỏi-đáp trên chính ghi chú (mini-RAG), chạy bằng Ollama local → riêng tư 100%.
- **Loại:** Productivity + AI
- **Bắt đầu:** 2026-06-30
- **Kiếm tiền:** Free + Premium IAP (AI RAG, auto-tag) + quảng cáo bản free.

## Roadmap (milestone)
- [x] **M1 — Nền tảng:** cấu trúc bài bản, model Note, lưu local, list + thêm/sửa/xóa, tìm kiếm, test. ✅ 2026-06-30
- [x] **M2 — Tích hợp Ollama:** gọi Ollama local + offline fallback; tóm tắt 1 ghi chú. ✅ 2026-07-02
- [x] **M3 — Mini-RAG:** index ghi chú (chunk + tìm kiếm ngữ nghĩa đơn giản), màn "Hỏi vault của bạn". ✅ 2026-07-02
- [x] **M4 — Tag tự động + lọc.** ✅ 2026-07-04
- [x] **M5 — UX polish:** dark mode, animation, icon, splash. ✅ 2026-07-07
- [ ] **M6 — Monetization:** Premium (in_app_purchase), paywall AI.
- [ ] **M7 — Ads + privacy:** AdMob, privacy policy, consent.
- [ ] **M8 — Publish:** screenshots, store listing, build aab/ipa, signing.

## ➡️ Milestone hiện tại (lần chạy kế tiếp)
**M6 — Monetization:** thêm `in_app_purchase`, model Premium (mở khóa AI RAG/auto-tag không giới hạn), màn paywall, giả lập mua hàng (sandbox chưa test được store thật — cần Mac mini cấu hình App Store Connect/Play Console sau).

## Changelog
- **2026-06-30** — Khởi tạo + xong M1: model Note, NoteRepository (lưu local), HomeScreen (list + search + xóa), EditScreen (thêm/sửa), widget NoteCard, test serialize. App chạy offline được, chưa có AI.
- **2026-07-02** — Xong M2 + M3: `OllamaService` (gọi REST API Ollama, không throw), `AiSettings` (host/model/bật-tắt, lưu local), `OfflineAi` (tóm tắt + trả lời fallback không cần mạng), `TextUtils` (tách câu/từ dùng chung). Mini-RAG: `RagService` chunk ghi chú + cosine similarity + `ask()`, màn `AskScreen` ("Hỏi vault của bạn") hiển thị câu trả lời + nguồn, màn `SettingsScreen` cấu hình Ollama + test kết nối. `EditScreen` thêm nút "Tóm tắt AI". 4 file test mới (rag_service, offline_ai, ollama_service, text_utils). Thêm dependency `http`. Version 0.2.0+2.
- **2026-07-04** — Xong M4: `AutoTagger` (từ điển ~40 chủ đề tiếng Việt + trích từ khóa theo tần suất, offline) và `ollamaSuggest`/`parseTagsResponse` (gợi ý tag qua Ollama, tự parse câu trả lời lộn xộn thành tag sạch), `StopwordsVi` (danh sách hư từ dùng để lọc). `NoteRepository` thêm `allTags` + `search(query, tags:)` lọc AND theo tag. Widget mới `TagFilterBar` (chip lọc trên HomeScreen, nhiều tag cùng lúc) và `TagChipInput` (thay ô nhập tag dạng text bằng chip, xóa từng tag). `EditScreen` thêm nút "Gợi ý tag" mở bottom sheet chọn tag đề xuất. 2 file test mới (auto_tagger, note_repository) với 14 test case. Version 0.3.0+3.
- **2026-07-07** — Xong M5: `ThemeSettings` (chọn sáng/tối/theo hệ thống, lưu local) + `SegmentedButton` trong `SettingsScreen` (đổi tên màn thành "Cài đặt", thêm mục "Giao diện"). Animation: `FadeSlideRoute`/`fadeSlideTo` (chuyển màn mờ dần + trượt nhẹ, áp dụng cho toàn bộ Navigator.push), `FadeSlideIn` (list item xuất hiện so le trên HomeScreen + nguồn trả lời trên AskScreen), `AnimatedSwitcher` cho khu vực loading→kết quả ở AskScreen, `AnimatedScale` cho chip lọc tag chọn và khi nhấn NoteCard (đổi `ListTile.onTap` sang `InkWell` bọc ngoài để bắt onTapDown/Up/Cancel). App icon + splash: tạo `assets/icon/icon.png` + `icon_foreground.png` + `assets/splash/splash_logo.png` (logo khiên teal #00B894, vẽ bằng PIL), cấu hình `flutter_launcher_icons` + `flutter_native_splash` trong `pubspec.yaml` (chưa chạy generate — cần Mac mini: `dart run flutter_launcher_icons` + `dart run flutter_native_splash:create`). 2 file test mới (theme_settings, fade_slide_in) 6 test case. Version 0.4.0+4.
