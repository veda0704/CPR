import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acls_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AclsApp shows login screen when not logged in',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AclsApp()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('EN'), findsOneWidget);
  });
}
