import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/profile_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadNotificationPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('notifications')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      loc.isBangla ? 'অর্ডার আপডেট ও ডেলিভারি স্ট্যাটাস' : 'Order & Delivery Updates',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      loc.isBangla ? 'অর্ডারের অগ্রগতি ও রাইডারের আগমন বার্তা পান' : 'Receive real-time alerts when your order changes state',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    value: profile.orderUpdatesOptIn,
                    onChanged: (val) {
                      profile.updateNotificationPreferences(
                        marketing: profile.marketingOptIn,
                        orderUpdates: val,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(
                      loc.isBangla ? 'অফার ও প্রমোশনাল নোটিফিকেশন' : 'Promotions & Discounts',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      loc.isBangla ? 'ডিসকাউন্ট কুপন ও বিশেষ ছাড়ের তথ্য পান' : 'Get notified of flash discounts and festival offers',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    value: profile.marketingOptIn,
                    onChanged: (val) {
                      profile.updateNotificationPreferences(
                        marketing: val,
                        orderUpdates: profile.orderUpdatesOptIn,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
