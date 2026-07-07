import 'package:flutter/material.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_Rule>[
      const _Rule(
        icon: Icons.grid_on,
        title: 'Mục tiêu',
        body: 'Xếp được 5 quân của mình liên tiếp theo hàng ngang, dọc hoặc chéo trước đối thủ.',
      ),
      const _Rule(
        icon: Icons.touch_app_outlined,
        title: 'Cách chơi',
        body: 'Chạm vào ô trống để đặt quân. Quân Đen luôn đi trước.',
      ),
      const _Rule(
        icon: Icons.smart_toy_outlined,
        title: 'Đấu với máy',
        body: 'Bạn luôn cầm quân Đen, máy (Trắng) sẽ tự động đi sau mỗi lượt của bạn. '
            'Chọn độ khó Dễ/Trung bình/Khó ở màn chọn chế độ.',
      ),
      const _Rule(
        icon: Icons.people_outline,
        title: '2 người chơi',
        body: 'Chơi luân phiên trên cùng 1 thiết bị, quân Đen và Trắng thay nhau đi.',
      ),
      const _Rule(
        icon: Icons.undo_rounded,
        title: 'Hoàn tác',
        body: 'Nhấn nút hoàn tác ở góc trên để rút lại nước vừa đi (đấu máy sẽ hoàn tác cả 2 nước).',
      ),
      const _Rule(
        icon: Icons.emoji_events_outlined,
        title: 'Kết thúc ván',
        body: 'Khi có 5 quân liên tiếp trở lên, ván đấu kết thúc ngay. Nếu bàn đầy mà chưa ai thắng thì hoà.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Hướng dẫn chơi')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final rule = items[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(rule.icon)),
              title: Text(rule.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(rule.body),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Rule {
  final IconData icon;
  final String title;
  final String body;

  const _Rule({required this.icon, required this.title, required this.body});
}
