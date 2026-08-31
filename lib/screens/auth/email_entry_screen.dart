import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ambient_glow_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/flame_mascot.dart';
import '../home/main_navigation_shell.dart';
import '../profile/support_screen.dart';
import 'otp_verify_screen.dart';

class EmailEntryScreen extends StatefulWidget {
  const EmailEntryScreen({super.key});

  @override
  State<EmailEntryScreen> createState() => _EmailEntryScreenState();
}

class _EmailEntryScreenState extends State<EmailEntryScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  MascotMood _mood = MascotMood.idle;
  String? _speech;

  @override
  void initState() {
    super.initState();
    _speech = 'Hi! Ready for gas delivery? 🔥';

    // Fast, snappy entrance animation (280ms)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _mood = MascotMood.typing;
          _updateSpeechForEmail(_emailController.text);
        });
      } else {
        setState(() {
          _mood = _emailController.text.isNotEmpty ? MascotMood.thinking : MascotMood.idle;
          _speech = null;
        });
      }
    });

    _emailController.addListener(() {
      if (_focusNode.hasFocus) {
        _updateSpeechForEmail(_emailController.text);
      }
    });
  }

  void _updateSpeechForEmail(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _mood = MascotMood.typing;
        _speech = 'Type your email below!';
      });
    } else if (trimmed.contains('@') && trimmed.contains('.')) {
      setState(() {
        _mood = MascotMood.celebrating;
        _speech = 'Looks great! Tap send 🔥';
      });
    } else if (trimmed.contains('@')) {
      setState(() {
        _mood = MascotMood.thinking;
        _speech = 'Almost done... 📬';
      });
    } else {
      setState(() {
        _mood = MascotMood.typing;
        _speech = 'Entering email... ✨';
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _mood = MascotMood.error;
        _speech = 'Please enter a valid email!';
      });
      return;
    }

    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim().toLowerCase();

    setState(() {
      _mood = MascotMood.thinking;
      _speech = 'Sending your 8-digit code... 📬';
    });

    final success = await auth.requestOtp(email);

    if (!mounted) return;

    if (success) {
      setState(() {
        _mood = MascotMood.celebrating;
      });
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) => OtpVerifyScreen(email: email),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 220),
        ),
      );
    } else if (auth.error != null) {
      setState(() {
        _mood = MascotMood.error;
        _speech = 'Oops, something went wrong!';
      });
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
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6600).withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
                          // Fast Animated Flame Mascot
                          Center(
                            child: FlameMascot(
                              mood: _mood,
                              size: 96,
                              speechBubbleText: _speech,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Header Titles
                          Text(
                            loc.isBangla ? 'গ্যাস লাগবে অ্যাপে স্বাগতম' : 'Welcome to Gas Lagba',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
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
                          const SizedBox(height: 28),

                          // Main Interactive Sign In Card
                          Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6600).withValues(alpha: 0.08),
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
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    hintText: loc.tr('emailHint'),
                                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                    prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFFFF6600), size: 20),
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
            ),
          ),
        ),
      ),
    );
  }
}
