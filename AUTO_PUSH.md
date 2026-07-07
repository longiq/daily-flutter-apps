# Tự động push app lên GitHub mỗi ngày (chạy trên Mac)

Task Cowork chỉ TẠO code (không push được vì chạy trong sandbox không có credential GitHub).
Để tự động đẩy lên GitHub, đặt 1 lịch cron NGAY TRÊN MÁY MAC — máy Mac có sẵn token/keychain nên push được.

## Bước 1 — đảm bảo push tay được trước
Chạy thử 1 lần cho chắc (đã lưu token, không hỏi mật khẩu nữa):
```bash
cd ~/ClaudeCreateApp
chmod +x scripts/push.sh
./scripts/push.sh
```

## Bước 2 — hẹn cron tự push mỗi sáng 7h (sau khi app tạo lúc 6h)
```bash
crontab -e
```
Thêm dòng:
```
0 7 * * * cd $HOME/ClaudeCreateApp && /bin/bash scripts/push.sh >> $HOME/ClaudeCreateApp/push.log 2>&1
```
Lưu lại (trong vim: nhấn `:wq`).

## Kiểm tra
- Xem log: `cat ~/ClaudeCreateApp/push.log`
- Xem cron đang có: `crontab -l`

## Điều kiện để cron chạy
- Máy Mac phải **đang bật/thức** lúc 7h (giống task tạo app lúc 6h).
- Token GitHub đã lưu (đã push tay thành công ít nhất 1 lần).

## Luồng hoàn chỉnh sau khi bật
```
6h00  máy thức
6h0x  Cowork tạo app mới trong apps/ hoặc longterm/
7h00  cron trên Mac tự push -> GitHub
7h0x  GitHub Actions tự test + build app vừa đổi
```
→ Bạn chỉ việc vào GitHub tải bản build khi cần.
