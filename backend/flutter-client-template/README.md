# Tích hợp Cloud AI (qua ai-proxy) vào 1 app Flutter hiện có

Áp dụng mô hình **3 lớp AI** cho mọi app AI (BudgetWise AI, Dream Oracle AI,
MindVault, FlashGen AI...):

```
1) CloudAiService  — qua ai-proxy trên Render, cần mạng, không cần cài gì
2) OllamaService    — Ollama local trên Mac mini, chỉ dùng khi dev/test
3) Offline*         — rule-based, luôn hoạt động, không cần mạng lẫn AI
```

Thử lần lượt 1 → 2 → 3, dùng kết quả đầu tiên khác `null`. App vẫn hoạt
động 100% dù không có mạng (rơi về lớp 3), nhưng người dùng thật (không cài
Ollama) vẫn có trải nghiệm AI đầy đủ nhờ lớp 1.

## Bước 1 — Copy file mẫu

```bash
cp ~/ClaudeCreateApp/backend/flutter-client-template/cloud_ai_service.dart \
   ~/ClaudeCreateApp/apps/<ten-app>/lib/services/cloud_ai_service.dart
```

## Bước 2 — Thêm cấu hình vào SettingsProvider

Thêm 3 field mới, lưu local giống hệt cách `ollamaHost`/`ollamaModel` đã
làm (ví dụ lấy từ `apps/budgetwise-ai/lib/providers/settings_provider.dart`):

```dart
static const _kCloudUrl = 'app_cloud_proxy_url';
static const _kCloudKey = 'app_cloud_proxy_key';
static const _kUseCloud = 'app_use_cloud_ai';

String cloudProxyUrl = 'https://ai-proxy-xxxx.onrender.com'; // [CHỈNH_Ở_ĐÂY]
String cloudProxyKey = '';
bool useCloudAi = true; // ưu tiên Cloud AI trước Ollama

// trong load(): đọc 3 giá trị trên từ SharedPreferences (như ollamaHost)
// thêm setCloudConfig({required url, required key, required enabled})
// tương tự setOllamaConfig đã có.
```

## Bước 3 — Sửa nơi đang gọi OllamaService, thêm lớp Cloud trước nó

Ví dụ cụ thể theo `apps/budgetwise-ai/lib/screens/insights_screen.dart`,
hàm `_runAiAnalysis`, đoạn:

```dart
// TRƯỚC (chỉ 2 lớp: Ollama -> offline)
String? result;
if (settings.ollamaEnabled) {
  final service = OllamaService(baseUrl: settings.ollamaHost, model: settings.ollamaModel);
  result = await service.analyzeSpending(summary);
}
```

Đổi thành:

```dart
// SAU (3 lớp: Cloud -> Ollama -> offline)
String? result;
if (settings.useCloudAi && settings.cloudProxyUrl.isNotEmpty) {
  final cloud = CloudAiService(
    baseUrl: settings.cloudProxyUrl,
    proxyKey: settings.cloudProxyKey,
  );
  result = await cloud.generate(promptChoTinhNangNay); // dùng lại prompt đang xây trong OllamaService
}
result ??= await () async {
  if (!settings.ollamaEnabled) return null;
  final service = OllamaService(baseUrl: settings.ollamaHost, model: settings.ollamaModel);
  return service.analyzeSpending(summary);
}();
// result == null -> UI đã có sẵn nhánh hiển thị offline fallback, giữ nguyên.
```

Lưu ý: `OllamaService` hiện có các hàm chuyên biệt (vd `analyzeSpending`,
`interpretDream`) tự xây prompt bên trong. `CloudAiService.generate()` nhận
prompt string trực tiếp — cách đơn giản nhất là copy đoạn xây prompt trong
hàm `OllamaService` tương ứng ra một hàm dùng chung (hoặc gọi thẳng
`buildXxxPrompt()` nếu tách sẵn), rồi truyền vào cả hai service.

## Bước 4 — Thêm UI ở SettingsScreen

Thêm 1 khối tương tự khối "Ollama (AI local)" đã có, đổi tên thành "Cloud AI
(proxy)": switch bật/tắt `useCloudAi`, 2 ô nhập `cloudProxyUrl` +
`cloudProxyKey`, nút "Kiểm tra kết nối" gọi `CloudAiService.testConnection()`.

## Bước 5 — Cập nhật README app

Thêm phần "Cấu hình Cloud AI" vào README của app, ghi rõ URL proxy mặc định
và cách người dùng tự đổi trong Cài đặt nếu bạn deploy proxy riêng.

## Ghi chú áp dụng cho app build tự động (task `daily-flutter-app`)

Từ lần build tiếp theo, app AI mới nên tạo `CloudAiService` này ngay từ đầu
(3 lớp) thay vì chỉ 2 lớp Ollama+offline như các app cũ — xem cập nhật
tương ứng trong `PROJECT_NOTES.md`.
