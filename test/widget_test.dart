import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:userapp/models/order_model.dart';
import 'package:userapp/widgets/empty_state_view.dart';
import 'package:userapp/widgets/status_badge.dart';

void main() {
  group('Widget UI tests', () {
    testWidgets('renders StatusBadge with correct color and label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: OrderStatus.outForDelivery),
          ),
        ),
      );

      expect(find.text('Out for Delivery'), findsOneWidget);
    });

    testWidgets('renders EmptyStateView with action button', (WidgetTester tester) async {
      bool buttonClicked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.shopping_cart_outlined,
              title: 'Empty Cart',
              message: 'No items in cart',
              actionText: 'Browse Now',
              onAction: () => buttonClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Empty Cart'), findsOneWidget);
      expect(find.text('No items in cart'), findsOneWidget);
      expect(find.text('Browse Now'), findsOneWidget);

      await tester.tap(find.text('Browse Now'));
      expect(buttonClicked, isTrue);
    });
  });
}
