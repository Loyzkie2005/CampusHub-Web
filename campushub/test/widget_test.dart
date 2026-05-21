import 'package:flutter_test/flutter_test.dart';
import 'package:campushub/main.dart';

void main() {
  testWidgets('intro screen shows main content', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusHubApp());

    expect(find.text('Campus'), findsOneWidget);
    expect(find.text('Hub'), findsOneWidget);
    expect(find.text('Everything Campus,\nAll in One Place.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
