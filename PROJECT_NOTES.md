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
└── longterm/    ← app dài hạn T3/5/7 (vd mindvault/)
```

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

**Mục tiêu hiệu chỉnh:** ~15-20 file hoặc ~1000-1500 dòng code mới/ngày, 4-6 màn hình, 3+ test (≈ gấp 3 lần build M1). Vẫn dừng khi đạt mục tiêu, không lặp vô hạn.
