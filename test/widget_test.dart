import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trabahotap/main.dart';
import 'package:trabahotap/providers/app_provider.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final appProvider = AppProvider();
    await appProvider.loadData();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appProvider,
        child: const TrabahoTapApp(),
      ),
    );
    await tester.pump();

    expect(find.text('TrabahoTap'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });
}
