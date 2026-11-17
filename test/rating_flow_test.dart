import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trabahotap/models/application.dart';
import 'package:trabahotap/providers/app_provider.dart';
import 'package:trabahotap/screens/applicants_screen.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('employer can submit a rating', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final app = AppProvider();
    await app.loadData();
    app.logIn('mark@example.com', '123456');
    await app.updateApplicationStatus('a5', ApplicationStatus.hired);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: app,
        child: const MaterialApp(home: ApplicantsScreen(jobId: 'j2')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rate Worker'), findsOneWidget);
    await tester.tap(find.text('Rate Worker'));
    await tester.pumpAndSettle();

    final stars = find.byIcon(Icons.star_border);
    expect(stars, findsWidgets);
    await tester.tap(stars.last);
    await tester.pump();
    await tester.tap(find.text('Submit Review'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Thank you for your review!'), findsOneWidget);
  });
}
