# Prompt build app cho Claude Code

> Chỉ cần thay `<TÊN_APP>` ở dòng đầu (vd `odd-color-tap`, `mindvault`), rồi dán cả khối vào Claude Code.

```
App cần build & chạy: <TÊN_APP>

Bối cảnh: Tôi có monorepo Flutter tại ~/ClaudeCreateApp (dùng đường dẫn tuyệt đối này, ĐỪNG giả định thư mục hiện tại). App nhỏ nằm ở apps/<tên>, app dài hạn ở longterm/<tên>. Mỗi app chỉ có code thuần (lib/, pubspec.yaml, test/), CHƯA có thư mục nền tảng android/ios/web.

Các bước:
1. Tìm thư mục app theo tên ở trên: kiểm tra ~/ClaudeCreateApp/apps/<TÊN_APP> và ~/ClaudeCreateApp/longterm/<TÊN_APP>, cd vào cái nào tồn tại.
2. Sinh thư mục nền tảng: flutter create --platforms=android,ios,web,macos .
3. Nếu flutter create sinh ra test/widget_test.dart tham chiếu class MyApp (không tồn tại — app dùng class riêng), thì xóa file đó. Giữ nguyên các test thật khác trong test/.
4. flutter pub get
5. Chạy flutter doctor; nếu thiếu CocoaPods thì cài (brew install cocoapods); xử lý mọi cảnh báo liên quan Xcode/iOS.
6. Mở iPhone Simulator: open -a Simulator, rồi flutter run -d iphone.
   (Muốn test nhanh không cần Xcode thì dùng: flutter run -d chrome)
7. Nếu build lỗi: đọc log, chẩn đoán và SỬA cho tới khi app chạy được. Giải thích ngắn gọn từng lỗi đã sửa.

Ràng buộc:
- KHÔNG commit các thư mục nền tảng vừa sinh (android/ios/web/macos) — đã có trong .gitignore.
- KHÔNG sửa logic/tính năng app; chỉ làm cho nó build & chạy được.
- Cuối cùng báo: app chạy được chưa + đã sửa những lỗi gì.
```
