// Backend proxy dùng chung cho các app Flutter AI của longiq.
//
// Mục đích: giấu GEMINI_API_KEY (không nhúng vào app build ra), expose 1
// endpoint /api/generate đơn giản mà mọi app Flutter (BudgetWise AI, Dream
// Oracle AI, MindVault, FlashGen AI, Cờ Caro AI...) đều gọi được, thay cho
// việc gọi thẳng Ollama local hoặc Gemini API trực tiếp từ app.
//
// Deploy free trên Render — xem README.md trong thư mục này.

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const app = express();

const PORT = process.env.PORT || 3000;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-2.5-flash';
const PROXY_SECRET = process.env.PROXY_SECRET || '';
const ALLOWED_ORIGINS = (process.env.ALLOWED_ORIGINS || '*')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);
const RATE_LIMIT_WINDOW_MS = Number(process.env.RATE_LIMIT_WINDOW_MS || 15 * 60 * 1000);
const RATE_LIMIT_MAX = Number(process.env.RATE_LIMIT_MAX || 30);
const MAX_PROMPT_CHARS = Number(process.env.MAX_PROMPT_CHARS || 8000);

if (!GEMINI_API_KEY) {
  console.error(
    '[ai-proxy] THIẾU biến môi trường GEMINI_API_KEY — server vẫn chạy nhưng ' +
      'mọi request /api/generate sẽ báo lỗi 500. Lấy key free tại ' +
      'https://aistudio.google.com/apikey rồi set trong Render > Environment.',
  );
}

app.use(
  cors({
    origin: ALLOWED_ORIGINS.includes('*') ? true : ALLOWED_ORIGINS,
  }),
);
app.use(express.json({ limit: '1mb' }));

// Kiểm tra "x-proxy-key" khớp PROXY_SECRET (nếu có cấu hình). Đây KHÔNG phải
// bảo mật thật sự (secret vẫn nằm trong app build ra, ai decompile cũng lấy
// được) — chỉ nhằm chặn bớt bot/scanner dò URL ngẫu nhiên và cho phép xoay
// vòng (rotate) secret nhanh mà không cần đổi GEMINI_API_KEY.
function checkProxySecret(req, res, next) {
  if (!PROXY_SECRET) return next(); // chưa cấu hình -> bỏ qua kiểm tra
  const provided = req.header('x-proxy-key');
  if (provided !== PROXY_SECRET) {
    return res.status(401).json({ error: 'Thiếu hoặc sai x-proxy-key.' });
  }
  next();
}

const generateLimiter = rateLimit({
  windowMs: RATE_LIMIT_WINDOW_MS,
  max: RATE_LIMIT_MAX,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Vượt giới hạn request, thử lại sau ít phút.' },
});

app.get('/', (req, res) => {
  res.json({ name: 'ai-proxy', status: 'ok', model: GEMINI_MODEL });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', model: GEMINI_MODEL, hasApiKey: Boolean(GEMINI_API_KEY) });
});

app.post('/api/generate', checkProxySecret, generateLimiter, async (req, res) => {
  try {
    if (!GEMINI_API_KEY) {
      return res.status(500).json({ error: 'Server chưa cấu hình GEMINI_API_KEY.' });
    }

    const { prompt, temperature, maxOutputTokens } = req.body || {};
    if (typeof prompt !== 'string' || prompt.trim().length === 0) {
      return res.status(400).json({ error: 'Thiếu "prompt" (string) trong body.' });
    }
    if (prompt.length > MAX_PROMPT_CHARS) {
      return res.status(400).json({
        error: `Prompt quá dài (tối đa ${MAX_PROMPT_CHARS} ký tự).`,
      });
    }

    const url =
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent` +
      `?key=${GEMINI_API_KEY}`;

    const geminiRes = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ role: 'user', parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: typeof temperature === 'number' ? temperature : 0.7,
          maxOutputTokens:
            typeof maxOutputTokens === 'number' ? maxOutputTokens : 800,
          // Gemini 2.5 Flash mặc định trích một phần maxOutputTokens cho
          // "thinking" (suy luận nội bộ, không hiển thị) trước khi sinh text
          // — với các tác vụ sinh text đơn giản (diễn giải, tóm tắt, tạo
          // thẻ...) việc này dễ ăn hết ngân sách token và cắt cụt câu trả
          // lời giữa chừng. Tắt hẳn vì không cần chain-of-thought ở đây.
          thinkingConfig: { thinkingBudget: 0 },
        },
      }),
    });

    const data = await geminiRes.json();

    if (!geminiRes.ok) {
      const message = data?.error?.message || 'Lỗi không xác định từ Gemini API.';
      console.error('[ai-proxy] Gemini API lỗi:', geminiRes.status, message);
      return res.status(502).json({ error: `Gemini API lỗi: ${message}` });
    }

    const text = data?.candidates?.[0]?.content?.parts?.map((p) => p.text || '').join('') ?? '';

    if (!text.trim()) {
      const finishReason = data?.candidates?.[0]?.finishReason;
      return res.status(502).json({
        error: `Gemini không trả về nội dung (finishReason: ${finishReason || 'unknown'}).`,
      });
    }

    res.json({ text: text.trim(), model: GEMINI_MODEL });
  } catch (err) {
    console.error('[ai-proxy] Lỗi xử lý /api/generate:', err);
    res.status(500).json({ error: 'Lỗi server nội bộ.' });
  }
});

app.use((req, res) => {
  res.status(404).json({ error: 'Không tìm thấy route.' });
});

app.listen(PORT, () => {
  console.log(`[ai-proxy] Đang chạy tại port ${PORT}, model=${GEMINI_MODEL}`);
});
