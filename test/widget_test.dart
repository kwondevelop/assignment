import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edencrew_assignment_starter/main.dart';

void main() {
  testWidgets('시작 화면이 다크 테마로 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(const EdencrewAssignmentApp());

    expect(find.text('이든크루 평가 과제'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
  });
}
