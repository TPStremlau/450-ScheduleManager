import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/home_page.dart';

void main() {
  testWidgets('Home Page has a title', (WidgetTester tester) async {
    await tester.pumpWidget(HomePage());
    final titleFinder = find.text('Home Page');
    expect(titleFinder, findsOneWidget);
  });

  testWidgets('Home Page has a button', (WidgetTester tester) async {
    await tester.pumpWidget(HomePage());
    final buttonFinder = find.byType(ElevatedButton);
    expect(buttonFinder, findsOneWidget);
  });

  testWidgets('Button click navigates to another page', (WidgetTester tester) async {
    await tester.pumpWidget(HomePage());
    final buttonFinder = find.byType(ElevatedButton);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    expect(find.text('Next Page'), findsOneWidget);
  });
}