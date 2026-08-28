import 'package:flutter_test/flutter_test.dart';
import 'package:userapp/models/order_model.dart';

void main() {
  group('Order state machine & cancellation permission tests', () {
    test('verifies active and terminal status boundaries', () {
      expect(OrderStatus.pending.isActive, isTrue);
      expect(OrderStatus.accepted.isActive, isTrue);
      expect(OrderStatus.preparing.isActive, isTrue);
      expect(OrderStatus.ready.isActive, isTrue);
      expect(OrderStatus.outForDelivery.isActive, isTrue);

      expect(OrderStatus.delivered.isTerminal, isTrue);
      expect(OrderStatus.cancelled.isTerminal, isTrue);
      expect(OrderStatus.rejected.isTerminal, isTrue);
    });

    test('verifies customer direct cancel permission only on PENDING (BR-100)', () {
      final pendingOrder = OrderModel(
        id: 'ord_1',
        orderNumber: 'GL-20260828-000001',
        vendorName: 'Vendor A',
        branchName: 'Branch 1',
        status: OrderStatus.pending,
        deliveryAddressText: 'Dhaka',
        subtotalPaisa: 140000,
        deliveryFeePaisa: 5000,
        totalPaisa: 145000,
        createdAt: DateTime.now(),
      );

      expect(pendingOrder.canCancelDirectly, isTrue);
      expect(pendingOrder.canRequestCancellation, isFalse);

      final acceptedOrder = OrderModel(
        id: 'ord_2',
        orderNumber: 'GL-20260828-000002',
        vendorName: 'Vendor A',
        branchName: 'Branch 1',
        status: OrderStatus.accepted,
        deliveryAddressText: 'Dhaka',
        subtotalPaisa: 140000,
        deliveryFeePaisa: 5000,
        totalPaisa: 145000,
        createdAt: DateTime.now(),
      );

      expect(acceptedOrder.canCancelDirectly, isFalse);
      expect(acceptedOrder.canRequestCancellation, isTrue);

      final outForDeliveryOrder = OrderModel(
        id: 'ord_3',
        orderNumber: 'GL-20260828-000003',
        vendorName: 'Vendor A',
        branchName: 'Branch 1',
        status: OrderStatus.outForDelivery,
        deliveryAddressText: 'Dhaka',
        subtotalPaisa: 140000,
        deliveryFeePaisa: 5000,
        totalPaisa: 145000,
        createdAt: DateTime.now(),
      );

      expect(outForDeliveryOrder.canCancelDirectly, isFalse);
      expect(outForDeliveryOrder.canRequestCancellation, isFalse);
    });
  });
}
