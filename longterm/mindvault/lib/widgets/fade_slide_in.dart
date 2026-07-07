import 'package:flutter/material.dart';

/// Bọc quanh 1 item (vd. NoteCard trong ListView) để item xuất hiện bằng
/// hiệu ứng mờ dần + trượt lên nhẹ, có thể trễ theo [index] để tạo hiệu
/// ứng "so le" (staggered) khi cả danh sách render lần đầu.
///
/// Dùng ValueKey theo id item ở nơi gọi để animation chạy lại đúng lúc item
/// mới xuất hiện (thêm/lọc) chứ không chạy lại mỗi lần rebuild vô ích.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 28),
    this.duration = const Duration(milliseconds: 260),
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _fade = curved;
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curved);

    // Giới hạn độ trễ tối đa để danh sách dài không "chờ" quá lâu mới xong.
    final delayMs =
        (widget.baseDelay.inMilliseconds * widget.index).clamp(0, 300).toInt();
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
