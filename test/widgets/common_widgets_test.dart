import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/widgets/empty_view.dart';
import 'package:movie_browser/widgets/error_view.dart';
import 'package:movie_browser/widgets/rating_badge.dart';

void main() {
  group('Common Widgets Tests', () {
    testWidgets('RatingBadge displays star icon and formatted rating', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RatingBadge(rating: 8.433))),
      );

      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.text('8.4'), findsOneWidget);
    });

    testWidgets('EmptyView displays title, message, and icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyView(
              title: 'Empty List',
              message: 'There are no items here.',
              icon: Icons.inbox_outlined,
            ),
          ),
        ),
      );

      expect(find.text('Empty List'), findsOneWidget);
      expect(find.text('There are no items here.'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('ErrorView displays message and triggers onRetry', (
      WidgetTester tester,
    ) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Network connection lost',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Oops! Something went wrong'), findsOneWidget);
      expect(find.text('Network connection lost'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, true);
    });
  });
}
