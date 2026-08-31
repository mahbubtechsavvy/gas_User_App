import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
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
    final email = _emailController.text.trim().toLowerCase();
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

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                loc.setLocale(loc.isBangla ? 'en' : 'bn');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language, size: 16, color: Color(0xFFFF6600)),
                    const SizedBox(width: 6),
                    Text(
                      loc.isBangla ? 'English' : 'বাংলা',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Brand Emblem
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF6600).withValues(alpha: 0.1),
                          ),
                        ),
                        Container(
                          width: 76,
                          height: 76,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF6600), Color(0xFFFF8C38)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x40FF6600),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header Titles
                  Text(
                    loc.isBangla ? 'গ্যাস লাগবে অ্যাপে স্বাগতম' : 'Welcome to Gas Lagba',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.isBangla
                        ? 'আপনার ইমেইল দিয়ে সহজে ও দ্রুত সাইন ইন করুন'
                        : 'Instant LPG Cylinder Delivery & Verified Brands Across Bangladesh',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Main Interactive Sign In Card
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'STEP 1 OF 2',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFF6600),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            const Text(
                              'Passwordless OTP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Text(
                          loc.tr('emailLabel'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: InputDecoration(
                            hintText: loc.tr('emailHint'),
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                            prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFFF6600), width: 2),
                            ),
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
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Guest Browsing Link
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                      );
                    },
                    icon: const Icon(Icons.storefront_outlined, size: 18, color: Color(0xFF475569)),
                    label: Text(
                      loc.isBangla ? 'অতিথি হিসেবে গ্যাস সিলিন্ডার দেখুন' : 'Explore Storefront as Guest',
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Help & Support Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.help_outline_rounded, size: 15, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SupportScreen()),
                          );
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          loc.tr('accountRecovery'),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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
