import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto() async {
    final loc = context.read<LocaleProvider>();
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primary),
              title: Text(
                loc.isBangla
                    ? 'ক্যামেরা দিয়ে ছবি তুলুন'
                    : 'Take Photo with Camera',
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primary),
              title: Text(
                loc.isBangla
                    ? 'গ্যালারি থেকে ছবি পছন্দ করুন'
                    : 'Choose from Gallery',
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _isUploadingPhoto = true);
        final bytes = await File(picked.path).readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        final success = await auth.updateCustomerProfile(
          fullName: user.fullName ?? '',
          phone: user.phone ?? '',
          avatarKey: base64String,
        );

        setState(() => _isUploadingPhoto = false);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  loc.isBangla
                      ? 'প্রোফাইল ছবি সফলভাবে আপডেট হয়েছে!'
                      : 'Profile photo updated successfully!',
                ),
                backgroundColor: AppTheme.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  auth.error ??
                      (loc.isBangla
                          ? 'ছবি আপলোড ব্যর্থ হয়েছে'
                          : 'Failed to update photo'),
                ),
                backgroundColor: AppTheme.danger,
              ),
            );
          }
        }
      }
    }
  }

  void _showEditProfileDialog() {
    final loc = context.read<LocaleProvider>();
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: user.fullName ?? '');
    final phoneController = TextEditingController(text: user.phone ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.isBangla ? 'প্রোফাইল সম্পাদনা' : 'Edit Profile',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: loc.isBangla ? 'পূর্ণ নাম' : 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? (loc.isBangla ? 'নাম আবশ্যক' : 'Name is required')
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: loc.isBangla ? 'মোবাইল নম্বর' : 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_android),
                    hintText: '01XXXXXXXXX',
                  ),
                  validator: (v) => v == null || v.trim().length < 11
                      ? (loc.isBangla
                            ? 'সঠিক মোবাইল নম্বর দিন'
                            : 'Enter valid phone number')
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setModalState(() => isSaving = true);
                          final ok = await auth.updateCustomerProfile(
                            fullName: nameController.text.trim(),
                            phone: phoneController.text.trim(),
                          );
                          setModalState(() => isSaving = false);
                          if (ctx.mounted && ok) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  loc.isBangla
                                      ? 'প্রোফাইল আপডেট হয়েছে!'
                                      : 'Profile updated!',
                                ),
                                backgroundColor: AppTheme.success,
                              ),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          loc.isBangla ? 'সংরক্ষণ করুন' : 'Save Changes',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              trailing: loc.locale == 'bn'
                  ? const Icon(Icons.check_circle, color: AppTheme.primary)
                  : null,
              onTap: () {
                loc.setLocale('bn');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: loc.locale == 'en'
                  ? const Icon(Icons.check_circle, color: AppTheme.primary)
                  : null,
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
        actions: [
          if (auth.isAuthenticated && user != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: loc.isBangla ? 'প্রোফাইল সম্পাদনা' : 'Edit Profile',
              onPressed: _showEditProfileDialog,
            ),
        ],
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
                    ? Column(
                        children: [
                          Row(
                            children: [
                              // Avatar with camera change button
                              Stack(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.primary.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: _isUploadingPhoto
                                          ? const Center(
                                              child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: AppTheme.primary,
                                                    ),
                                              ),
                                            )
                                          : (user.avatarUrl != null &&
                                                    user.avatarUrl!.isNotEmpty
                                                ? (user.avatarUrl!.startsWith(
                                                        'data:',
                                                      )
                                                      ? Image.memory(
                                                          base64Decode(
                                                            user.avatarUrl!
                                                                .split(',')
                                                                .last,
                                                          ),
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                _,
                                                                __,
                                                                ___,
                                                              ) => const Icon(
                                                                Icons.person,
                                                                color: AppTheme
                                                                    .primary,
                                                                size: 36,
                                                              ),
                                                        )
                                                      : Image.network(
                                                          user.avatarUrl!,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                _,
                                                                __,
                                                                ___,
                                                              ) => const Icon(
                                                                Icons.person,
                                                                color: AppTheme
                                                                    .primary,
                                                                size: 36,
                                                              ),
                                                        ))
                                                : const Icon(
                                                    Icons.person,
                                                    color: AppTheme.primary,
                                                    size: 36,
                                                  )),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: _pickAndUploadPhoto,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName ?? 'Customer',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.phone ?? user.email,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (user.phone != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        user.email,
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (user.uniqueCode != null) ...[
                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: user.uniqueCode!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      loc.isBangla
                                          ? 'ইউনিক আইডি কপি হয়েছে!'
                                          : 'Unique ID copied to clipboard!',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.fingerprint,
                                      color: AppTheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            loc.isBangla
                                                ? 'আপনার অনন্য আইডি'
                                                : 'Your Unique User ID',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.textSecondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '#${user.uniqueCode}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primary,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.copy,
                                      color: AppTheme.primary,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: AppTheme.primary,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.tr('welcomeGuest'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.tr('loginToContinue'),
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const EmailEntryScreen(),
                                ),
                              );
                            },
                            child: Text(loc.tr('login')),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Profile completion notice if needed
            if (auth.isAuthenticated && user != null && !user.isProfileComplete)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.warning,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.tr('completeProfileNotice'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loc.tr('completeProfilePrompt'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProfileSetupScreen(),
                            ),
                          );
                        },
                        child: Text(loc.tr('edit')),
                      ),
                    ],
                  ),
                ),
              ),

            // Settings & Options List
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.primary,
                    ),
                    title: Text(loc.tr('addressBook')),
                    subtitle: Text(loc.tr('addressBookDesc')),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      if (!auth.isAuthenticated) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EmailEntryScreen(),
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddressBookScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.primary,
                    ),
                    title: Text(loc.tr('notifications')),
                    subtitle: Text(loc.tr('notificationsDesc')),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.language_outlined,
                      color: AppTheme.primary,
                    ),
                    title: Text(loc.tr('language')),
                    subtitle: Text(
                      loc.locale == 'bn' ? 'বাংলা (Bangla)' : 'English',
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => _showLanguageDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.headset_mic_outlined,
                      color: AppTheme.primary,
                    ),
                    title: Text(loc.tr('helpSupport')),
                    subtitle: Text(loc.tr('helpSupportDesc')),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SupportScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: AppTheme.primary,
                    ),
                    title: Text(loc.tr('aboutUs')),
                    subtitle: const Text(
                      'Gas Lagba ${AppConfig.appVersion} (${AppConfig.appBuildNumber})',
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Gas Lagba',
                        applicationVersion: AppConfig.appVersion,
                        applicationLegalese:
                            '© 2026 GT Group. All rights reserved.',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (auth.isAuthenticated)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  side: const BorderSide(color: AppTheme.danger),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout),
                label: Text(loc.tr('logout')),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
