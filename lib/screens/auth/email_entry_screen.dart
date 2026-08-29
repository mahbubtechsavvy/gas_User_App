import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
// DEV-LOGIN-BACKDOOR — remove this import and the button below with lib/dev/dev_login.dart.
import '../../dev/dev_login.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../home/main_navigation_shell.dart';
import '../profile/support_screen.dart';
import 'otp_verify_screen.dart';

class EmailEntryScreen extends StatefulWidget {
  const EmailEntryScreen({super.key});

  @override
  State<EmailEntryScreen> createState() => _EmailEntryScreenState();
}

class _EmailEntryScreenState extends State<EmailEntryScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final success = await auth.requestOtp(email);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerifyScreen(email: email),
        ),
      );
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  /// DEV-LOGIN-BACKDOOR — TEMPORARY. Skips the email code entirely; debug builds only.
  void _devLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.devLogin();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dev login is not available in this build')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          TextButton.icon(
            onPressed: () {
              loc.setLocale(loc.isBangla ? 'en' : 'bn');
            },
            icon: const Icon(Icons.language, size: 18),
            label: Text(loc.isBangla ? 'English' : 'বাংলা'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_gas_station,
                        size: 56,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.tr('welcomeBack'),
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.tr('authSubtitle'),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.tr('emailLabel'),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: loc.tr('emailHint'),
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return loc.tr('invalidEmail');
                              }
                              final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                              if (!emailRegex.hasMatch(val.trim())) {
                                return loc.tr('invalidEmail');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: loc.tr('sendOtp'),
                            isLoading: auth.isLoading,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                      );
                    },
                    child: Text(
                      loc.isBangla ? 'অতিথি হিসেবে পণ্য দেখুন' : 'Browse Catalogue as Guest',
                      style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  // DEV-LOGIN-BACKDOOR — TEMPORARY, debug builds only. Remove with
                  // lib/dev/dev_login.dart once the backend is complete.
                  if (DevLogin.enabled) ...[
                    const SizedBox(height: 4),
                    OutlinedButton.icon(
                      onPressed: auth.isLoading ? null : _devLogin,
                      icon: const Icon(Icons.bug_report_outlined, size: 18),
                      label: const Text('Dev Login'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade900,
                        side: BorderSide(color: Colors.orange.shade700),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Frontend testing only — removed before release.',
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.help_outline, size: 16, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SupportScreen()),
                          );
                        },
                        child: Text(
                          loc.tr('accountRecovery'),
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
