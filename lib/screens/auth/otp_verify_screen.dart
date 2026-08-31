import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/ambient_glow_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/flame_mascot.dart';
import '../home/main_navigation_shell.dart';
import 'profile_setup_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;

  const OtpVerifyScreen({super.key, required this.email});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> with TickerProviderStateMixin {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  int _secondsRemaining = 60;
  Timer? _timer;
  MascotMood _mascotMood = MascotMood.idle;
  String? _speechBubble;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _speechBubble = 'Check your email!';

    // Snappy entrance animation (280ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
    _entranceController.forward();

    // Fast error shake animation (300ms)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _mascotMood = MascotMood.typing;
          _updateMascotForOtp(_otpController.text);
        });
      } else {
        setState(() {
          _mascotMood = _otpController.text.isNotEmpty ? MascotMood.thinking : MascotMood.idle;
          _speechBubble = null;
        });
      }
    });

    _otpController.addListener(() {
      final text = _otpController.text;
      _updateMascotForOtp(text);

      // Auto-submit when user reaches 8 digits for an ultra-fast seamless login!
      if (text.trim().length == 8) {
        _verify();
      }
    });
  }

  void _updateMascotForOtp(String text) {
    final len = text.length;
    if (len == 8 || len == 6) {
      setState(() {
        _mascotMood = MascotMood.thinking;
        _speechBubble = 'Verifying code... 🚀';
      });
    } else if (len > 0) {
      setState(() {
        _mascotMood = MascotMood.typing;
        _speechBubble = '$len / 8 digits entered';
      });
    } else {
      setState(() {
        _mascotMood = MascotMood.idle;
        _speechBubble = 'Check your email!';
      });
    }
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
    _entranceController.dispose();
    _shakeController.dispose();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _verify() async {
    if (!_formKey.currentState!.validate()) {
      _shakeController.forward(from: 0.0);
      setState(() {
        _mascotMood = MascotMood.error;
        _speechBubble = 'Please enter 8 digits!';
      });
      return;
    }

    final auth = context.read<AuthProvider>();
    final code = _otpController.text.trim();

    setState(() {
      _mascotMood = MascotMood.thinking;
      _speechBubble = 'Verifying code... ⏳';
    });

    final success = await auth.verifyOtp(widget.email, code);

    if (!mounted) return;

    if (success) {
      setState(() {
        _mascotMood = MascotMood.celebrating;
        _speechBubble = 'Success! Welcome 🎉';
      });

      // Sync address and cart
      context.read<AddressProvider>().fetchAddresses();
      context.read<CartProvider>().fetchCart();

      // Quick smooth 200ms delay for celebration pop
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      final user = auth.currentUser;
      if (user != null && !user.isProfileComplete) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, anim, secAnim) => const ProfileSetupScreen(),
            transitionsBuilder: (context, a, secAnim, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 200),
          ),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, anim, secAnim) => const MainNavigationShell(),
            transitionsBuilder: (context, a, secAnim, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 200),
          ),
          (route) => false,
        );
      }
    } else {
      _shakeController.forward(from: 0.0);
      setState(() {
        _mascotMood = MascotMood.error;
        _speechBubble = 'Incorrect code! ❌';
      });

      if (auth.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error!),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _resend() async {
    if (_secondsRemaining > 0) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.requestOtp(widget.email);
    if (!mounted) return;

    if (success) {
      _startCountdown();
      setState(() {
        _mascotMood = MascotMood.idle;
        _speechBubble = 'New code sent! 📬';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locText(context, 'A new login code has been sent.', 'নতুন ৮-সংখ্যার কোড পাঠানো হয়েছে।')),
          backgroundColor: AppTheme.success,
        ),
      );
    } else if (auth.error != null) {
      setState(() {
        _mascotMood = MascotMood.error;
        _speechBubble = 'Failed to resend!';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  String locText(BuildContext context, String en, String bn) {
    return context.read<LocaleProvider>().isBangla ? bn : en;
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
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AmbientGlowBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Fast Interactive Flame Mascot Character
                          Center(
                            child: FlameMascot(
                              mood: _mascotMood,
                              size: 96,
                              speechBubbleText: _speechBubble,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            loc.isBangla ? 'ভেরিফিকেশন কোড লিখুন' : 'Verify Your Email',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Recipient Chip
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 340),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF6600).withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.email_outlined, size: 14, color: Color(0xFFFF6600)),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      widget.email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        loc.isBangla ? 'বদলান' : 'Edit',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF6600),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Animated Shake Verification Card
                          AnimatedBuilder(
                            animation: _shakeController,
                            builder: (context, child) {
                              final offset = (math.sin(_shakeAnim.value * math.pi * 6) * 10.0) * (1.0 - _shakeAnim.value);
                              return Transform.translate(
                                offset: Offset(offset, 0),
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(22.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF6600).withValues(alpha: 0.08),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        loc.isBangla ? '৮-সংখ্যার কোড' : '8-DIGIT CODE',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF64748B),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      if (_secondsRemaining > 0)
                                        Text(
                                          loc.isBangla
                                              ? '$_secondsRemaining সেকেন্ড বাকি'
                                              : 'Resend in ${_secondsRemaining}s',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFFF6600),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Monospace OTP input field (Supports 8-digit and 6-digit codes)
                                  TextFormField(
                                    controller: _otpController,
                                    focusNode: _focusNode,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 8,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 6,
                                      color: Color(0xFF1E293B),
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      hintText: '••••••••',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade300,
                                        letterSpacing: 6,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                                      if (val == null || (val.trim().length != 8 && val.trim().length != 6)) {
                                        return loc.tr('invalidOtp');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 22),

                                  CustomButton(
                                    text: loc.tr('verifyOtp'),
                                    isLoading: auth.isLoading,
                                    icon: Icons.check_circle_outline_rounded,
                                    onPressed: _verify,
                                  ),
                                  const SizedBox(height: 14),

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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
