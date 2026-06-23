import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/google_auth_service.dart';

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onSuccess;
  final Function(String error)? onError;

  const GoogleSignInButton({super.key, this.onSuccess, this.onError});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final GoogleAuthService _googleAuth = GoogleAuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoading) return;

    setState(() => _isLoading = true);

    try {
      final googleUser = await _googleAuth.signInWithGoogle();
      if (googleUser == null) {
        widget.onError?.call('Google Sign-In was cancelled.');
        return;
      }

      if (!mounted) return;

      final authentication = await _googleAuth.authenticate(googleUser);
      if (authentication?.idToken == null || authentication!.idToken!.isEmpty) {
        throw Exception('Could not obtain Google ID token. Firebase may not be configured.');
      }
      final idToken = authentication.idToken!;

      final success = await authProvider.googleSignIn(
        googleId: googleUser.id,
        idToken: idToken,
        email: googleUser.email,
        name: googleUser.displayName ?? googleUser.email,
        phone: '',
        profilePhoto: googleUser.photoUrl,
      );

      if (!success && mounted) {
        widget.onError?.call(authProvider.error ?? 'Google Sign-In failed');
      } else if (mounted) {
        widget.onSuccess?.call();
      }
    } catch (e) {
      widget.onError?.call(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) => SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: _isLoading || auth.isLoading ? null : _handleGoogleSignIn,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading || auth.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/google_logo.png',
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.login, size: 24);
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
