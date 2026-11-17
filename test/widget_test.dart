// Smoke test for Al-Muazzen: the app boots to the Arabic root scaffold
// with its five navigation destinations. The master switch is mocked OFF
// so no notification plugin calls are made in the test environment.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:al_muazzen/main.dart';

void main() {
  testWidgets('App boots to root scaffold with 5 tabs', (tester) async {
    SharedPreferences.setMockInitialValues({'master_enabled': false});
    await tester.pumpWidget(const MuazzenApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('الصلاة'), findsWidgets);
    expect(find.text('الأذكار'), findsWidgets);
    expect(find.text('السبحة'), findsWidgets);
    expect(find.text('القبلة'), findsWidgets);
    expect(find.text('الإعدادات'), findsWidgets);
  });
}
