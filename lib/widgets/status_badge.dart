import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/order_model.dart';

class StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case OrderStatus.pending:
        bg = AppTheme.warningLight;
        fg = AppTheme.warning;
        label = 'Pending';
        break;
      case OrderStatus.accepted:
        bg = AppTheme.primaryLight;
        fg = AppTheme.primary;
        label = 'Accepted';
        break;
      case OrderStatus.preparing:
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF4338CA);
        label = 'Preparing';
        break;
      case OrderStatus.ready:
        bg = const Color(0xFFEDE9FE);
        fg = const Color(0xFF6D28D9);
        label = 'Ready';
        break;
      case OrderStatus.outForDelivery:
        bg = AppTheme.accentLight;
        fg = AppTheme.accent;
        label = 'Out for Delivery';
        break;
      case OrderStatus.delivered:
        bg = AppTheme.successLight;
        fg = AppTheme.success;
        label = 'Delivered';
        break;
      case OrderStatus.cancelled:
        bg = AppTheme.dangerLight;
        fg = AppTheme.danger;
        label = 'Cancelled';
        break;
      case OrderStatus.rejected:
        bg = AppTheme.dangerLight;
        fg = AppTheme.danger;
        label = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
