import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/shared/shared.dart';

void main() {
  testWidgets('the lockup reserves its box before the artwork decodes',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: WorkSettleTheme.light,
        home: const Scaffold(body: Center(child: WsWordmark(width: 220))),
      ),
    );

    // Nothing has decoded on the first frame. An `Image` given only a width
    // occupies no height at all until it has, and then jumps to full size —
    // which moved everything laid out around it. The height comes from the
    // artwork's own 1215 × 401 proportions instead, so the box is right from
    // the first frame and never changes.
    final box = tester.getRect(find.byType(WsWordmark));
    expect(box.width, 220);
    expect(box.height, moreOrLessEquals(220 * 401 / 1215, epsilon: 0.5));
  });
}
