import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acls_mobile/features/simulation/step_screen.dart';
import 'package:acls_mobile/features/simulation/step_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('StepScreen displays a step and navigates to completion',
      (WidgetTester tester) async {
    final stepData = {
      'id': 'scene_safety_start',
      'title': 'Scene Safety Start',
      'question': 'Is the area safe?',
      'choices': [
        {'label': 'Yes', 'next': 'dashboard'},
      ],
    };

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stepProvider.overrideWith((ref, stepId) async => stepData),
        ],
        child: const MaterialApp(
          home: StepScreen(stepId: 'scene_safety_start'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Scene Safety Start'), findsOneWidget);
    expect(find.text('Is the area safe?'), findsOneWidget);
    expect(find.text('YES'), findsOneWidget);

    await tester.ensureVisible(find.text('YES'));
    await tester.tap(find.text('YES'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Module Complete!'), findsOneWidget);
  });
}
