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
- [ ] **M2 — Tích hợp Ollama:** gọi Ollama local + offline fallback; tóm tắt 1 ghi chú.
- [ ] **M3 — Mini-RAG:** index ghi chú (chunk + tìm kiếm ngữ nghĩa đơn giản), màn "Hỏi vault của bạn".
- [ ] **M4 — Tag tự động + lọc.**
- [ ] **M5 — UX polish:** dark mode, animation, icon, splash.
- [ ] **M6 — Monetization:** Premium (in_app_purchase), paywall AI.
- [ ] **M7 — Ads + privacy:** AdMob, privacy policy, consent.
- [ ] **M8 — Publish:** screenshots, store listing, build aab/ipa, signing.

## ➡️ Milestone hiện tại (lần chạy kế tiếp)
**M2 — Tích hợp Ollama**

## Changelog
- **2026-06-30** — Khởi tạo + xong M1: model Note, NoteRepository (lưu local), HomeScreen (list + search + xóa), EditScreen (thêm/sửa), widget NoteCard, test serialize. App chạy offline được, chưa có AI.
