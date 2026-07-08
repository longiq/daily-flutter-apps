# Ghi nhớ dự án "App mỗi ngày"

## Môi trường của user (longiq)
- **Máy chạy Cowork:** Mac mini M4, ở **nhà**, mạng **không giới hạn** → build/test thoải mái.
- **Ở công ty:** KHÔNG dùng được Cowork (mạng nội bộ hạn chế).
- Có macOS → build được **cả iOS lẫn Android**.
- Có thể dùng **Ollama local** hoặc API cloud tự do (ở nhà không bị chặn).

## Hệ quả khi build app
- App nên **build được trên macOS M4** (Apple Silicon).
- App AI: ưu tiên **Ollama local** + luôn có **offline fallback** để chạy được không cần mạng.
- Giữ dependency tối thiểu, `flutter run` chạy ngay.
- Sandbox của Cowork KHÔNG có Flutter và bị chặn mạng → không build/test trong sandbox được. Test thật phải chạy trên Mac mini.

## Cấu trúc thư mục
```
ClaudeCreateApp/
├── apps/        ← app nhỏ T2/4/6 (chỉ tên app, vd odd-color-tap/; ngày lưu ở INDEX.md)
├── longterm/    ← app dài hạn T3/5/7 (vd mindvault/)
└── backend/     ← ai-proxy (backend chung, xem mục "AI backend chung" bên dưới)
```

## AI backend chung (ai-proxy) — thêm 2026-07-08
Ollama local chỉ tiện cho lúc **dev/test trên Mac mini** — người dùng thật
cài app từ store sẽ KHÔNG có Ollama chạy sẵn. Để app AI hoạt động ngay cả
với người dùng thật mà không lộ API key trong file build, dùng backend
proxy nhỏ deploy free trên Render:

- **Vị trí:** `backend/ai-proxy/` (Node/Express, gọi Gemini API free tier
  ~1.500 request/ngày, key giữ ở server qua env var `GEMINI_API_KEY`).
- **Cách deploy:** xem `backend/ai-proxy/README.md` (deploy từ GitHub repo
  đã có sẵn qua `AUTO_PUSH.md`, root directory `backend/ai-proxy`).
- **Client mẫu cho Flutter:** `backend/flutter-client-template/` — copy
  `cloud_ai_service.dart` vào từng app + làm theo hướng dẫn trong README ở
  đó để chuyển từ 2 lớp (Ollama → offline) sang **3 lớp**:
  `CloudAiService (qua proxy) → OllamaService (local, dev) → Offline (rule-based, luôn có)`.
- **Trạng thái áp dụng (cập nhật 2026-07-08):** đã sửa 3 lớp vào **Dream
  Oracle AI, BudgetWise AI, FlashGen AI** (dùng chung `PROXY_SECRET` nhúng
  trong code — chấp nhận được vì đây không phải secret cấp cao, xem README
  ai-proxy). **CHƯA sửa** MindVault, Cờ Caro AI — áp dụng dần khi
  build/nâng cấp.
- **Quy ước cho app AI mới (task `daily-flutter-app`):** từ app AI tiếp
  theo, tạo `CloudAiService` ngay từ đầu theo template thay vì chỉ 2 lớp
  Ollama+offline như trước đây (đọc `backend/flutter-client-template/README.md`
  trước khi build).
- URL proxy thật (đã deploy trên Render 2026-07-08): **`https://ai-proxy-2f7q.onrender.com`**
  (health check: `GET /health`, gọi thật: `POST /api/generate` kèm header `x-proxy-key`).

## Lệnh test nhanh trên Mac mini
```bash
cd ~/ClaudeCreateApp/apps/<ten-app>     # hoặc longterm/<ten>
flutter pub get
flutter run -d macos     # hoặc -d chrome / -d <iphone-sim>
```

## Lịch tự động (cập nhật)
- **T2 / T4 / T6** — task `daily-flutter-app`: mỗi ngày 1 app nhỏ MỚI, phức tạp vừa phải (2-4 màn, state mgmt, lưu data, test, cấu trúc bài bản). Luân phiên game / AI.
- **T3 / T5 / T7** — task `flutter-longterm-project`: phát triển tiếp 1 app dài hạn theo roadmap (xem `ONGOING.md`), tích lũy qua nhiều ngày để publish được.
- **Chủ nhật** — nghỉ.
- Phạm vi mỗi ngày: chỉn chu nhưng dừng đúng lúc (~15% công sức/ngày, 1 vòng code + 1 vòng review).
- Log app nhỏ ở `INDEX.md`; app dài hạn theo dõi ở `ONGOING.md`.

## Calibration log (canh token ~15%/ngày)
Mình không đọc được token trực tiếp → canh bằng quy mô (số file/dòng/tool-call) + % thực tế user báo.

| Ngày | Build | Proxy (file / ~dòng) | % thực tế | Ghi chú |
|------|-------|----------------------|-----------|---------|
| 2026-06-30 | MindVault M1 | 7 file Dart / ~400 dòng / ~15 ghi file | **< 5%** | Quá nhỏ → cần gấp ~3 lần |
| 2026-07-01 | Math Sprint | 24 file Dart / ~1757 dòng / ~24 ghi file | _(điền)_ | Đã làm lớn ~3x: 6 màn, provider, prefs, 3 test |
| 2026-07-02 | MindVault M2+M3 | 16 file mới/đổi / ~1240 dòng / ~16 ghi file | _(điền)_ | Ollama service + offline fallback + mini-RAG (chunk+cosine) + 2 màn mới + 4 test mới |
| 2026-07-03 | Dream Oracle AI | 20 file Dart / ~1960 dòng / ~24 ghi file | _(điền)_ | App mới: nhật ký giấc mơ + Ollama + offline interpreter (từ điển 40 biểu tượng) + 6 màn + provider + 4 test |
| 2026-07-04 | MindVault M4 | 10 file mới/đổi / ~954 dòng / ~10 ghi file | _(điền)_ | Tag tự động + lọc: AutoTagger (từ điển 40 chủ đề + tần suất từ, offline) + ollamaSuggest, StopwordsVi, NoteRepository.allTags/search(tags:), TagFilterBar + TagChipInput, nút "Gợi ý tag" ở EditScreen, 2 file test/14 case |
| 2026-07-06 | Cờ Caro AI | 21 file Dart / ~2030 dòng / ~25 ghi file | _(điền)_ | Game mới: Gomoku 5 quân, 2 người/đấu AI (heuristic pattern-score 4 hướng + nhìn trước 1 nước ở Khó), 3 cỡ bàn, 6 màn, provider, prefs (settings+history), 4 file test/24 case |
| 2026-07-07 | MindVault M5 | 13 file mới/đổi (2 ảnh PNG) / ~750 dòng / ~13 ghi file | _(điền)_ | UX polish: ThemeSettings (sáng/tối/hệ thống, lưu local) + SegmentedButton trong SettingsScreen; FadeSlideRoute/fadeSlideTo (chuyển màn) + FadeSlideIn (list so le) + AnimatedSwitcher (AskScreen) + AnimatedScale (chip tag, NoteCard press); app icon + splash (PIL, chưa generate — cần Mac mini), 2 file test mới/6 case |
| 2026-07-08 | BudgetWise AI | 25 file Dart (lib) + 4 test / ~2830 dòng / ~29 ghi file | _(điền)_ | App mới: quản lý thu chi cá nhân, danh mục cố định (8 chi + 4 thu), TransactionProvider (CRUD + tổng hợp theo tháng), BudgetRepository + BudgetProgressBar cảnh báo vượt hạn mức, OfflineInsights (5 loại nhận xét quy tắc, luôn offline) + OllamaService phân tích chuyên sâu (giới hạn 3 lượt free/tháng, Premium mô phỏng), RootShell bottom-nav 4 tab + màn Cài đặt riêng, 6 màn hình, 4 file test/20 case |

**Mục tiêu hiệu chỉnh:** ~15-20 file hoặc ~1000-1500 dòng code mới/ngày, 4-6 màn hình, 3+ test (≈ gấp 3 lần build M1). Vẫn dừng khi đạt mục tiêu, không lặp vô hạn.
