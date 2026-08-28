import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/order_model.dart';

class OrderTimelineWidget extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderTimelineWidget({super.key, required this.currentStatus});

  static const List<Map<String, dynamic>> _steps = [
    {'status': OrderStatus.pending, 'label': 'Order Placed', 'icon': Icons.receipt_long},
    {'status': OrderStatus.accepted, 'label': 'Accepted', 'icon': Icons.check_circle_outline},
    {'status': OrderStatus.preparing, 'label': 'Preparing', 'icon': Icons.propane_tank},
    {'status': OrderStatus.ready, 'label': 'Ready', 'icon': Icons.inventory_2_outlined},
    {'status': OrderStatus.outForDelivery, 'label': 'Out for Delivery', 'icon': Icons.delivery_dining},
    {'status': OrderStatus.delivered, 'label': 'Delivered', 'icon': Icons.home},
  ];

  int _getStatusStepIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.accepted:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.outForDelivery:
        return 4;
      case OrderStatus.delivered:
        return 5;
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentStatus == OrderStatus.cancelled || currentStatus == OrderStatus.rejected) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.dangerLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel, color: AppTheme.danger, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                currentStatus == OrderStatus.cancelled
                    ? 'This order has been cancelled.'
                    : 'This order was rejected by the branch.',
                style: const TextStyle(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final currentIdx = _getStatusStepIndex(currentStatus);

    return Column(
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isCompleted = index <= currentIdx;
        final isCurrent = index == currentIdx;
        final isLast = index == _steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppTheme.primary
                        : (isCompleted ? AppTheme.success : AppTheme.border),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted && !isCurrent ? Icons.check : (step['icon'] as IconData),
                    color: isCompleted ? Colors.white : AppTheme.textMuted,
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 32,
                    color: index < currentIdx ? AppTheme.success : AppTheme.border,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  step['label'] as String,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : (isCompleted ? FontWeight.w600 : FontWeight.normal),
                    color: isCurrent ? AppTheme.primary : (isCompleted ? AppTheme.textPrimary : AppTheme.textMuted),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
