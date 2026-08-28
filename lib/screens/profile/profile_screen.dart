import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/email_entry_screen.dart';
import '../auth/profile_setup_screen.dart';
import 'address_book_screen.dart';
import 'notification_settings_screen.dart';
import 'support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLanguageDialog(BuildContext context) {
    final loc = context.read<LocaleProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.tr('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇧🇩', style: TextStyle(fontSize: 24)),
              title: const Text('বাংলা (Bangla)'),
              trailing: loc.locale == 'bn' ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
              onTap: () {
                loc.setLocale('bn');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: loc.locale == 'en' ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
              onTap: () {
                loc.setLocale('en');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final loc = context.read<LocaleProvider>();
    final auth = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.tr('logout')),
        content: Text(loc.tr('logoutConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const EmailEntryScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(loc.tr('logout')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('profile')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Info Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: auth.isAuthenticated && user != null
                    ? Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: AppTheme.primary, size: 36),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName ?? 'Customer',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.phone ?? user.email,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                ),
                                if (user.phone != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primary),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
                              );
                            },
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const Icon(Icons.account_circle, size: 50, color: AppTheme.textMuted),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.isBangla ? 'অতিথি অ্যাকাউন্ট' : 'Guest Account',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.isBangla ? 'অর্ডার সম্পন্ন করতে লগইন করুন' : 'Log in to place orders and save addresses',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const EmailEntryScreen()),
                              );
                            },
                            child: Text(loc.isBangla ? 'লগইন' : 'Log In', style: const TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Settings Menu Items
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: AppTheme.primary),
                    title: Text(loc.tr('myAddresses'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                    onTap: () {
                      if (!auth.isAuthenticated) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmailEntryScreen()));
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddressBookScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_outlined, color: AppTheme.primary),
                    title: Text(loc.tr('language'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(loc.isBangla ? 'বাংলা' : 'English', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                      ],
                    ),
                    onTap: () => _showLanguageDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined, color: AppTheme.primary),
                    title: Text(loc.tr('notifications'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.headset_mic_outlined, color: AppTheme.primary),
                    title: Text(loc.tr('support'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SupportScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            if (auth.isAuthenticated) ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.danger),
                  title: Text(
                    loc.tr('logout'),
                    style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onTap: () => _confirmLogout(context),
                ),
              ),
            ],

            const SizedBox(height: 32),
            Text(
              '${AppConfig.appName} v${AppConfig.appVersion}',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              loc.tr('tagline'),
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
