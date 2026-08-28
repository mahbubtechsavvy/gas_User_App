import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/money_text.dart';
import '../../widgets/status_badge.dart';
import '../home/main_navigation_shell.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final orderProv = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('orders')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: [
            Tab(text: loc.tr('activeOrders')),
            Tab(text: loc.tr('orderHistory')),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => orderProv.fetchOrders(),
        color: AppTheme.primary,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOrderList(context, orderProv.activeOrders, loc, isActive: true),
            _buildOrderList(context, orderProv.historyOrders, loc, isActive: false),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    List<OrderModel> orders,
    LocaleProvider loc, {
    required bool isActive,
  }) {
    if (orders.isEmpty) {
      return EmptyStateView(
        icon: Icons.receipt_long_outlined,
        title: isActive
            ? (loc.isBangla ? 'কোনো সক্রিয় অর্ডার নেই' : 'No active orders')
            : (loc.isBangla ? 'কোনো পূর্ববর্তী অর্ডার নেই' : 'No past orders yet'),
        message: isActive
            ? (loc.isBangla ? 'নতুন গ্যাস সিলিন্ডার অর্ডার করতে হোম পেজে যান।' : 'Browse gas branches to place a new order.')
            : (loc.isBangla ? 'আপনার সম্পন্ন হওয়া অর্ডারগুলো এখানে সংরক্ষিত থাকবে।' : 'Your completed and delivered orders will appear here.'),
        actionText: isActive ? (loc.isBangla ? 'সিলিন্ডার ব্রাউজ করুন' : 'Browse Gas') : null,
        onAction: isActive
            ? () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                  (route) => false,
                );
              }
            : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderTrackingScreen(orderId: order.id),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#${order.orderNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      StatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${order.vendorName} (${order.branchName})',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.items.length} ${loc.isBangla ? 'টি পণ্য' : 'items'} • ${DateFormat('dd MMM, yyyy - hh:mm a').format(order.createdAt)}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('${loc.isBangla ? 'সর্বমোট: ' : 'Total: '} ', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                          MoneyText(
                            money: order.total,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            loc.isBangla ? 'বিস্তারিত' : 'Details',
                            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.primary),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
