import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/widgets/fade_slide_in.dart';

void main() {
  testWidgets('FadeSlideIn bắt đầu mờ và hiện rõ dần sau khi settle',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FadeSlideIn(
          index: 0,
          child: Text('Xin chào'),
        ),
      ),
    );

    // Ngay khung hình đầu tiên: chưa kịp forward, độ mờ ban đầu = 0.
    final fadeFinder = find.byType(FadeTransition);
    expect(fadeFinder, findsOneWidget);
    var fade = tester.widget<FadeTransition>(fadeFinder);
    expect(fade.opacity.value, 0.0);

    await tester.pumpAndSettle();

    fade = tester.widget<FadeTransition>(fadeFinder);
    expect(fade.opacity.value, 1.0);
    expect(find.text('Xin chào'), findsOneWidget);
  });

  testWidgets('index lớn hơn thì trễ hơn (chưa forward ngay sau vài ms đầu)',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FadeSlideIn(
          index: 5,
          baseDelay: Duration(milliseconds: 28),
          child: Text('Trễ'),
        ),
      ),
    );

    // Mới pump 10ms, độ trễ dự kiến 5*28=140ms nên animation chưa bắt đầu.
    await tester.pump(const Duration(milliseconds: 10));
    final fade = tester.widget<FadeTransition>(find.byType(FadeTransition));
    expect(fade.opacity.value, 0.0);

    await tester.pumpAndSettle();
    final fadeDone = tester.widget<FadeTransition>(find.byType(FadeTransition));
    expect(fadeDone.opacity.value, 1.0);
  });
}
