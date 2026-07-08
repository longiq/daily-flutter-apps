# ai-proxy

Backend proxy nhỏ (Node + Express) dùng chung cho tất cả app Flutter AI của
bạn (BudgetWise AI, Dream Oracle AI, MindVault, FlashGen AI, Cờ Caro AI...).

**Vấn đề nó giải quyết:** gọi thẳng Gemini API từ app Flutter thì API key bị
nhúng vào file build (APK/IPA) — ai decompile cũng lấy được, dùng ké quota
free của bạn. `ai-proxy` giữ key ở phía server (Render), app chỉ gọi 1
endpoint đơn giản, không bao giờ thấy key thật.

## Endpoint

```
POST /api/generate
Content-Type: application/json
x-proxy-key: <PROXY_SECRET nếu có cấu hình>

{ "prompt": "Nội dung cần AI xử lý", "temperature": 0.7, "maxOutputTokens": 800 }
```

Trả về:
```json
{ "text": "Kết quả AI trả lời", "model": "gemini-2.5-flash" }
```
Lỗi trả về `{ "error": "mô tả lỗi" }` kèm mã HTTP phù hợp (400/401/429/500/502).

```
GET /health  ->  { "status": "ok", "model": "...", "hasApiKey": true }
```

## Bước 1 — Lấy Gemini API key (free, không cần thẻ)

1. Vào https://aistudio.google.com/apikey
2. Đăng nhập Google, bấm **Create API key**.
3. Copy key — đây là `GEMINI_API_KEY`. Free tier ~1.500 request/ngày với
   `gemini-2.5-flash` (đủ dùng thoải mái cho vài app cá nhân).

## Bước 2 — Chạy thử local (tùy chọn, cần Node ≥ 20)

```bash
cd ~/ClaudeCreateApp/backend/ai-proxy
cp .env.example .env
# Mở .env, dán GEMINI_API_KEY vừa lấy vào, tự đặt PROXY_SECRET tùy ý
npm install
npm start
# Server chạy ở http://localhost:3000
curl -X POST http://localhost:3000/api/generate \
  -H "Content-Type: application/json" \
  -H "x-proxy-key: <PROXY_SECRET bạn đặt>" \
  -d '{"prompt":"Xin chào bằng 1 câu tiếng Việt"}'
```

## Bước 3 — Deploy lên Render (free)

Repo `ClaudeCreateApp` của bạn đã tự động push lên GitHub mỗi sáng (xem
`AUTO_PUSH.md` ở gốc repo) — Render deploy thẳng từ GitHub nên chỉ cần làm
1 lần:

1. Tạo tài khoản tại https://render.com (free, đăng nhập bằng GitHub luôn
   cho tiện).
2. **New +** → **Web Service** → chọn repo GitHub `ClaudeCreateApp`.
3. Ở bước cấu hình:
   - **Root Directory:** `backend/ai-proxy`
   - **Runtime:** Node
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Instance Type:** Free
4. Mục **Environment Variables**, thêm:
   - `GEMINI_API_KEY` = key ở Bước 1
   - `PROXY_SECRET` = 1 chuỗi tự đặt (vd tạo bằng `openssl rand -hex 16`)
   - (tùy chọn) `GEMINI_MODEL`, `RATE_LIMIT_MAX`, `ALLOWED_ORIGINS` — để mặc
     định nếu không rõ cần chỉnh gì.
5. Bấm **Create Web Service**. Chờ build xong (~1-2 phút), Render cho bạn 1
   URL dạng `https://ai-proxy-xxxx.onrender.com`.
6. Test: `curl https://ai-proxy-xxxx.onrender.com/health`

Có sẵn `render.yaml` trong thư mục này nếu bạn muốn deploy qua **Blueprint**
(New + → Blueprint → chọn repo) thay vì cấu hình tay ở bước 3-4.

## Lưu ý về gói Free của Render

- Free Web Service của Render sẽ **ngủ (spin down) sau ~15 phút không có
  request**, request đầu tiên sau đó mất thêm ~30-50 giây để "đánh thức".
  Bình thường với app cá nhân dùng không thường xuyên, chỉ cần app tự
  retry/hiện loading khi gọi lần đầu.
- Nếu cần luôn "nóng" (không ngủ), phải nâng lên gói trả phí, hoặc tự ping
  `/health` định kỳ bằng 1 cron job free (vd cron-job.org) — đánh đổi là
  tốn thêm request vào quota Gemini free nếu ping trúng lúc app cũng gọi.

## Cập nhật sau khi sửa code

Vì Render tự deploy lại mỗi khi có commit mới trên nhánh đã chọn, chỉ cần
`git push` (qua `scripts/push.sh` như thường lệ) là Render tự build lại.

## Áp dụng vào app Flutter

Xem `../flutter-client-template/README.md` để lấy code mẫu `CloudAiService`
và cách thêm vào 1 app hiện có theo mô hình 3 lớp: **Cloud AI (qua proxy
này) → Ollama local → offline rule-based fallback**.
