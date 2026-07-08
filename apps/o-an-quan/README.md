# Ô Ăn Quan (web, chạy local)

Game dân gian Ô Ăn Quan chơi trực tiếp trên trình duyệt, không cần cài đặt gì. Người chơi (dưới) đấu với máy (trên).

## Tính năng
- Bàn cờ 10 ô dân + 2 ô quan, rải quân và ăn quân liên hoàn theo luật đơn giản hoá (xem nút "Luật chơi" trong app).
- 3 mức AI:
  - **Dễ**: đi ngẫu nhiên trong các nước hợp lệ.
  - **Trung bình**: chọn nước ăn được nhiều quân nhất ngay lượt đó (tham lam 1 nước).
  - **Khó**: minimax + alpha-beta cắt tỉa, nhìn trước ~5 nửa nước đi.
- Log lịch sử nước đi, hiệu ứng nhấp nháy ô vừa bị ăn, kết thúc ván tự tính điểm quân còn lại cho chủ ô.

## Chạy thử
Không cần build. Chọn 1 trong 2 cách:

```bash
cd ~/ClaudeCreateApp/apps/o-an-quan
open index.html                 # mở thẳng bằng trình duyệt mặc định
# hoặc chạy server tĩnh để tránh giới hạn CORS của một số trình duyệt
python3 -m http.server 8811
# rồi mở http://localhost:8811
```

## Cấu trúc
```
index.html   giao diện + modal luật chơi / kết thúc ván
style.css    theme gỗ nâu, bàn cờ, hiệu ứng
script.js    toàn bộ logic: rải quân, ăn quân liên hoàn, kết thúc ván, AI 3 mức độ
```
