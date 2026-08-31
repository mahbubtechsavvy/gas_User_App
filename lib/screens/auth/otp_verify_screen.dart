import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_button.dart';
import '../home/main_navigation_shell.dart';
import 'profile_setup_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;

  const OtpVerifyScreen({super.key, required this.email});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _verify() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final code = _otpController.text.trim();
    final success = await auth.verifyOtp(widget.email, code);

    if (!mounted) return;

    if (success) {
      // Sync address and cart
      context.read<AddressProvider>().fetchAddresses();
      context.read<CartProvider>().fetchCart();

      final user = auth.currentUser;
      if (user != null && !user.isProfileComplete) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
          (route) => false,
        );
      }
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  void _resend() async {
    if (_secondsRemaining > 0) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.requestOtp(widget.email);
    if (!mounted) return;

    if (success) {
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new 6-digit login code has been sent.'),
          backgroundColor: AppTheme.success,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
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
                  // Icon Header
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF6600).withValues(alpha: 0.1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mark_email_read_outlined,
                          size: 40,
                          color: Color(0xFFFF6600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    loc.isBangla ? 'ভেরিফিকেশন কোড লিখুন' : 'Verify Your Email',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Recipient Chip
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email, size: 14, color: Color(0xFFFF6600)),
                          const SizedBox(width: 6),
                          Text(
                            widget.email,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Verification Card
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '6-DIGIT CODE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (_secondsRemaining > 0)
                              Text(
                                'Resend in ${_secondsRemaining}s',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF6600),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Monospace OTP input field
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 12,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '••••••',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade300,
                              letterSpacing: 12,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                            if (val == null || val.trim().length != 6) {
                              return loc.tr('invalidOtp');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        CustomButton(
                          text: loc.tr('verifyOtp'),
                          isLoading: auth.isLoading,
                          icon: Icons.check_circle_outline_rounded,
                          onPressed: _verify,
                        ),
                        const SizedBox(height: 16),

                        // Resend Button
                        Center(
                          child: TextButton(
                            onPressed: _secondsRemaining == 0 ? _resend : null,
                            child: Text(
                              loc.tr('resendOtp'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _secondsRemaining == 0
                                    ? const Color(0xFFFF6600)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
