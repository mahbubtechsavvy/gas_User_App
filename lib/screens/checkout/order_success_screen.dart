import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/money_text.dart';
import '../home/main_navigation_shell.dart';
import '../order/order_tracking_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final List<OrderModel> orders;

  const OrderSuccessScreen({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 72,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  loc.isBangla ? 'অর্ডার সফলভাবে গৃহীত হয়েছে!' : 'Order Placed Successfully!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.isBangla
                      ? 'সংশ্লিষ্ট গ্যাস ব্রাঞ্চ আপনার অর্ডারটি দ্রুত প্রস্তুত ও সরবরাহ করবে।'
                      : 'The respective gas branch will prepare and dispatch your order promptly.',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Order Cards List
                ...orders.map((order) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        '${loc.tr('orderNumber')}: ${order.orderNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('${order.vendorName} (${order.branchName})', style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(loc.isBangla ? 'মোট: ' : 'Total: ', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              MoneyText(
                                money: order.total,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrderTrackingScreen(orderId: order.id),
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 28),

                CustomButton(
                  text: loc.isBangla ? 'অর্ডার ট্র্যাক করুন' : 'Track Orders',
                  icon: Icons.receipt_long,
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MainNavigationShell(initialIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: loc.isBangla ? 'হোম পেজে ফিরুন' : 'Back to Home',
                  isOutlined: true,
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
