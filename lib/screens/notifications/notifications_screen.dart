import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../order/order_tracking_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final notifProv = context.watch<NotificationProvider>();
    final notifications = notifProv.notifications;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('notifications')),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => notifProv.markAllAsRead(),
              child: Text(
                loc.isBangla ? 'সব পঠিত করুন' : 'Mark all read',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifProv.fetchNotifications(),
        color: AppTheme.primary,
        child: notifications.isEmpty
            ? EmptyStateView(
                icon: Icons.notifications_none,
                title: loc.isBangla ? 'কোনো নোটিফিকেশন নেই' : 'No notifications',
                message: loc.isBangla
                    ? 'আপনার অর্ডারের সব আপডেট এখানে দেখতে পাবেন।'
                    : 'All order status updates and promo alerts will appear here.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return _buildNotificationCard(context, notif, notifProv);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notif,
    NotificationProvider notifProv,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: notif.isRead ? AppTheme.surface : const Color(0xFFF0F6FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notif.isRead ? AppTheme.border : const Color(0xFFB8D5FF),
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!notif.isRead) notifProv.markAsRead(notif.id);
          final orderId = notif.metadata?['orderId']?.toString();
          if (orderId != null && orderId.isNotEmpty) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OrderTrackingScreen(orderId: orderId),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notif.isRead ? Colors.grey.shade100 : AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notif.category == 'ORDER_UPDATE' ? Icons.delivery_dining : Icons.campaign_outlined,
                  color: notif.isRead ? AppTheme.textMuted : AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('dd MMM, hh:mm a').format(notif.createdAt),
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
