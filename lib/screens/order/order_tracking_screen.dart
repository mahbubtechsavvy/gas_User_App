import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/money_text.dart';
import '../../widgets/order_timeline_widget.dart';
import '../../widgets/status_badge.dart';
import '../ratings/rate_order_dialog.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrderDetails(widget.orderId);
    });
  }

  void _showCancelDialog(OrderModel order) {
    final loc = context.read<LocaleProvider>();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(order.canCancelDirectly ? loc.tr('cancelOrder') : loc.tr('requestCancel')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.canCancelDirectly
                  ? (loc.isBangla ? 'অর্ডারটি এখনও কনফার্ম হয়নি, আপনি এটি সরাসরি বাতিল করতে পারবেন।' : 'This order has not been accepted yet, you can cancel it directly.')
                  : (loc.isBangla ? 'অর্ডারটি প্রক্রিয়াধীন, আপনার বাতিলের অনুরোধটি ব্রাঞ্চ যাচাই করবে।' : 'The order is in progress. Your cancellation request will be reviewed by the branch.'),
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: loc.tr('cancelReason'),
                hintText: loc.isBangla ? 'যেমন: অন্য সিলিন্ডার পেয়েছি' : 'e.g. Ordered by mistake',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () async {
              final reason = reasonController.text.trim();
              Navigator.pop(ctx);
              final orderProv = context.read<OrderProvider>();
              final success = await orderProv.cancelOrder(order.id, reason.isNotEmpty ? reason : 'Customer request');

              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.isBangla ? 'বাতিল কার্যক্রম সম্পন্ন হয়েছে' : 'Cancellation processed'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            child: Text(order.canCancelDirectly ? loc.tr('cancelOrder') : loc.tr('requestCancel')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final orderProv = context.watch<OrderProvider>();
    final order = orderProv.currentOrder;

    if (orderProv.isLoading && order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('#${order.orderNumber}'),
      ),
      body: RefreshIndicator(
        onRefresh: () => orderProv.fetchOrderDetails(widget.orderId),
        color: AppTheme.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.vendorName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          StatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.branchName} • ${DateFormat('dd MMM, yyyy - hh:mm a').format(order.createdAt)}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                      if (order.branchPhone != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 14, color: AppTheme.primary),
                            const SizedBox(width: 4),
                            Text(order.branchPhone!, style: const TextStyle(fontSize: 13, color: AppTheme.primary)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Status Timeline
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isBangla ? 'ডেলিভারি স্ট্যাটাস' : 'Delivery Progress',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      OrderTimelineWidget(currentStatus: order.status),
                    ],
                  ),
                ),
              ),

              // Assigned Rider Card
              if (order.riderName != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delivery_dining, color: AppTheme.accent, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.tr('riderDetails'), style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                              const SizedBox(height: 2),
                              Text(order.riderName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              if (order.riderPhone != null)
                                Text(order.riderPhone!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        if (order.riderPhone != null)
                          IconButton(
                            icon: const Icon(Icons.phone, color: AppTheme.success),
                            onPressed: () {
                              launchUrl(Uri.parse('tel:${order.riderPhone}'));
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              // Scheduled Window / ASAP Info
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.tr('deliveryMode'),
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.deliveryMode == 'SCHEDULED' && order.deliverySlotFormatted != null
                                  ? order.deliverySlotFormatted!
                                  : loc.tr('asapDelivery'),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Delivery Address Card
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.accent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.tr('deliveryAddress'), style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            const SizedBox(height: 2),
                            Text(order.deliveryAddressText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Items Summary
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isBangla ? 'অর্ডারের বিবরণ' : 'Order Items',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      ...order.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.productName} (${item.variantName})',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    Text(
                                      '${item.quantity} x ${item.unitPrice.format()}${item.depositPaisa > 0 ? ' + Dep. ${item.deposit.format()}' : ''}',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              MoneyText(money: item.lineTotal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(loc.tr('subtotal'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          MoneyText(money: order.subtotal, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (order.depositTotalPaisa > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(loc.tr('cylinderDepositTotal'), style: const TextStyle(color: AppTheme.accent, fontSize: 13)),
                            MoneyText(money: order.depositTotal, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.accent)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(loc.tr('deliveryFee'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          MoneyText(money: order.deliveryFee, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(loc.tr('grandTotal'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          MoneyText(
                            money: order.total,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Rate & Review button if delivered
              if (order.status == OrderStatus.delivered)
                CustomButton(
                  text: loc.tr('rateVendor'),
                  icon: Icons.star_border,
                  backgroundColor: const Color(0xFFFFB800),
                  textColor: Colors.black,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => RateOrderDialog(order: order),
                    );
                  },
                ),

              // Cancel Actions
              if (order.canCancelDirectly || order.canRequestCancellation) ...[
                const SizedBox(height: 12),
                CustomButton(
                  text: order.canCancelDirectly ? loc.tr('cancelOrder') : loc.tr('requestCancel'),
                  isOutlined: true,
                  backgroundColor: AppTheme.danger,
                  textColor: AppTheme.danger,
                  onPressed: () => _showCancelDialog(order),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
