import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/models/order.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/providers/order_provider.dart';
import 'package:userapp/screens/order/order_tracking_screen.dart';
import 'package:userapp/screens/ratings/ratings_screen.dart';

class OrdersScreen extends StatefulWidget {
  final String? orderId;

  const OrdersScreen({super.key, this.orderId});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;
    await context.read<OrderProvider>().loadOrders(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: Consumer<OrderProvider>(
          builder: (context, orderProvider, child) {
            if (orderProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (orderProvider.error != null) {
              return Center(child: Text(orderProvider.error!));
            }

            final orders = orderProvider.orders;
            if (orders.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No orders found.'),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _buildOrderCard(orders[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      child: ListTile(
        title: Text(order.orderNumber),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Vendor: ${order.shopName}'),
            Text('Total: ৳${order.totalAmount.toStringAsFixed(2)}'),
            if (order.createdAt != null)
              Text(
                'Date: ${_formatDate(order.createdAt!)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            const SizedBox(height: 4),
            Text(
              _statusLabel(order.orderStatus),
              style: TextStyle(
                color: _statusColor(order.orderStatus),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.blue),
              tooltip: 'Track Order',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OrderTrackingScreen(orderId: order.id),
                  ),
                );
              },
            ),
            if (order.orderStatus == 'delivered')
              IconButton(
                icon: const Icon(Icons.star, color: Colors.amber),
                tooltip: 'Rate Vendor',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RatingsScreen(
                        orderId: order.id,
                        vendorId: order.vendorId,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
