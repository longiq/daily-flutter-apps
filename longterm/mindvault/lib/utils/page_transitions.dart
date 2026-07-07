import 'package:flutter/material.dart';

/// Route chuyển màn dùng chung: fade + trượt nhẹ từ dưới lên, thay cho
/// MaterialPageRoute mặc định để app có cảm giác mượt hơn (M5 - UX polish).
class FadeSlideRoute<T> extends PageRouteBuilder<T> {
  FadeSlideRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 260),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Helper ngắn gọn: `Navigator.push(context, fadeSlideTo((_) => Screen()))`.
Route<T> fadeSlideTo<T>(WidgetBuilder builder) =>
    FadeSlideRoute<T>(builder: builder);
