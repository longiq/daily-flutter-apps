import 'package:flutter/material.dart';

/// Ô nhập tag dạng chip: hiển thị các tag hiện có (xóa được bằng nút x) +
/// một ô nhập nhỏ để gõ tag mới, nhấn Enter hoặc dấu phẩy để thêm.
/// Là "controlled component" — cha giữ state [tags], widget chỉ báo thay
/// đổi qua [onChanged] để cha (EditScreen) dễ dàng cộng thêm tag gợi ý từ
/// AutoTagger vào cùng danh sách.
class TagChipInput extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  const TagChipInput({super.key, required this.tags, required this.onChanged});

  @override
  State<TagChipInput> createState() => _TagChipInputState();
}

class _TagChipInputState extends State<TagChipInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addFromField() {
    final raw = _controller.text;
    if (raw.trim().isEmpty) return;
    final parts = raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
    final next = List<String>.from(widget.tags);
    for (final p in parts) {
      if (!next.contains(p)) next.add(p);
    }
    _controller.clear();
    widget.onChanged(next);
  }

  void _remove(String tag) {
    widget.onChanged(widget.tags.where((t) => t != tag).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final tag in widget.tags)
            InputChip(
              label: Text(tag),
              onDeleted: () => _remove(tag),
            ),
          SizedBox(
            width: 140,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Thêm tag...',
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _addFromField(),
              onChanged: (v) {
                if (v.endsWith(',')) _addFromField();
              },
            ),
          ),
        ],
      ),
    );
  }
}
