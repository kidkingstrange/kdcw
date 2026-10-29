import 'package:flutter_test/flutter_test.dart';
import 'package:kdrama_crosswords/main.dart';

void main() {
  testWidgets('KDramaCrosswordsApp smoke test mounts cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const KDramaCrosswordsApp());
    expect(find.text('K-DRAMA'), findsOneWidget);
    expect(find.text('Crosswords'), findsOneWidget);
  });
}
