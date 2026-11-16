import 'package:flutter_test/flutter_test.dart';

import 'package:trabahotap/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TrabahoTapApp());
    expect(find.text('TrabahoTap'), findsWidgets);
  });
}
