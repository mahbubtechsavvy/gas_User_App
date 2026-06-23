import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/models/order.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/providers/order_provider.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrder();
      // Poll every 20 seconds so the user sees live status updates
      _pollingTimer = Timer.periodic(
        const Duration(seconds: 20),
        (_) => _loadOrder(),
      );
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    if (!mounted) return;
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;
    await context.read<OrderProvider>().loadOrder(token, widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading && orderProvider.selectedOrder == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orderProvider.error != null && orderProvider.selectedOrder == null) {
            return Center(child: Text(orderProvider.error!));
          }

          final order = orderProvider.selectedOrder;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildOrderInfo(order),
                _buildItems(order),
                _buildTimeline(order.orderStatus),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone),
                    label: const Text('Contact Vendor'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderInfo(Order order) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(order.orderStatus).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _statusLabel(order.orderStatus),
                    style: TextStyle(
                      color: _statusColor(order.orderStatus),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Vendor: ${order.shopName}'),
            Text('Total: ৳${order.totalAmount.toStringAsFixed(2)}'),
            Text('Address: ${order.deliveryAddress}'),
            if (order.notes != null && order.notes!.isNotEmpty)
              Text('Notes: ${order.notes}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.refresh, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Auto-refreshes every 20s',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItems(Order order) {
    if (order.items.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: order.items.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) {
          final item = order.items[index];
          return Row(
            children: [
              if (item.productImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.productImage!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              else
                const Icon(Icons.propane_tank),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName),
                    Text(
                      '${item.quantity} x ৳${item.price.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text('৳${item.total.toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeline(String status) {
    final timeline = const [
      'pending',
      'accepted',
      'processing',
      'out_for_delivery',
      'delivered',
    ];
    final currentIndex = timeline.indexOf(status);
    final activeIndex = currentIndex < 0 ? 0 : currentIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Timeline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...timeline.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isCompleted = index <= activeIndex;
            final isLast = index == timeline.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? Colors.green : Colors.grey[300],
                        border: Border.all(
                          color: isCompleted ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 60,
                        color: isCompleted ? Colors.green : Colors.grey[300],
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _statusLabel(item),
                      style: TextStyle(
                        fontWeight:
                            isCompleted ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
