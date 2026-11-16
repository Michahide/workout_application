import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_application/main.dart';

void main() {
  testWidgets('WorkoutTrackerApp renders bottom navigation shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WorkoutTrackerApp(),
      ),
    );

    expect(find.text('Gyms'), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
    expect(find.text('Plans'), findsOneWidget);
    expect(find.text('Workout'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
  });
}
