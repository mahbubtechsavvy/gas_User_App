import 'dart:math' as math;
import 'package:flutter/material.dart';

enum MascotMood {
  idle,
  typing,
  celebrating,
  thinking,
  error,
}

class FlameMascot extends StatefulWidget {
  final MascotMood mood;
  final double size;
  final String? speechBubbleText;

  const FlameMascot({
    super.key,
    this.mood = MascotMood.idle,
    this.size = 110,
    this.speechBubbleText,
  });

  @override
  State<FlameMascot> createState() => _FlameMascotState();
}

class _FlameMascotState extends State<FlameMascot> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _flickerController;
  late AnimationController _blinkController;
  late AnimationController _celebrateController;
  late AnimationController _wiggleController;

  @override
  void initState() {
    super.initState();

    // Fast, buoyant floating bounce (950ms vs old 2200ms)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);

    // Swift energetic flame flicker & pulse (500ms vs old 1400ms)
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // Snappy natural blinking
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Instant celebration jump (320ms)
    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    // Dynamic typing wiggle/tilt (280ms)
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant FlameMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood == MascotMood.celebrating && oldWidget.mood != MascotMood.celebrating) {
      _celebrateController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _flickerController.dispose();
    _blinkController.dispose();
    _celebrateController.dispose();
    _wiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatController,
        _flickerController,
        _blinkController,
        _celebrateController,
        _wiggleController,
      ]),
      builder: (context, child) {
        // Quick dynamic curves
        final floatCurved = Curves.easeInOutSine.transform(_floatController.value);
        final floatOffset = (floatCurved * 10.0) - 5.0;
        final flickerScale = 0.95 + (_flickerController.value * 0.10);
        final isBlinking = _blinkController.value > 0.92 && _blinkController.value < 0.98;
        final celebrateBounce = math.sin(_celebrateController.value * math.pi) * -22.0;

        // Dynamic typing wiggle tilt
        double tiltAngle = 0.0;
        if (widget.mood == MascotMood.typing) {
          tiltAngle = (math.sin(_wiggleController.value * math.pi * 2) * 0.06);
        } else if (widget.mood == MascotMood.celebrating) {
          tiltAngle = (math.sin(_celebrateController.value * math.pi * 4) * 0.08);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick Animated Speech Bubble (Scale & Fade)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: widget.speechBubbleText != null
                  ? Container(
                      key: ValueKey<String>(widget.speechBubbleText!),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6600).withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFFFD4B8), width: 1.5),
                      ),
                      child: Text(
                        widget.speechBubbleText!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFC2410C),
                          letterSpacing: -0.2,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),

            // Animated Flame Mascot Canvas with dynamic float, bounce, and quick tilt
            Transform.translate(
              offset: Offset(0, floatOffset + celebrateBounce),
              child: Transform.rotate(
                angle: tiltAngle,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size * 1.15,
                  child: CustomPaint(
                    painter: _FlamePainter(
                      flickerProgress: _flickerController.value,
                      flickerScale: flickerScale,
                      isBlinking: isBlinking,
                      mood: widget.mood,
                    ),
                  ),
                ),
              ),
            ),

            // Soft Dynamic Hover Shadow Underneath
            Transform.scale(
              scale: 1.0 - (floatCurved * 0.22),
              child: Container(
                width: widget.size * 0.55,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6600).withValues(alpha: 0.22),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FlamePainter extends CustomPainter {
  final double flickerProgress;
  final double flickerScale;
  final bool isBlinking;
  final MascotMood mood;

  _FlamePainter({
    required this.flickerProgress,
    required this.flickerScale,
    required this.isBlinking,
    required this.mood,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h * 0.58);

    // 1. Ambient Flame Aura Glow
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF6600).withValues(alpha: 0.35),
          const Color(0xFFFFB800).withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.65));
    canvas.drawCircle(center, w * 0.65 * flickerScale, auraPaint);

    // 2. Outer Flame Body
    final outerPath = Path();
    final outerTipX = w * 0.50 + math.sin(flickerProgress * math.pi * 2) * 4;
    final outerTipY = h * 0.08;

    outerPath.moveTo(outerTipX, outerTipY);
    // Right flame curvature
    outerPath.cubicTo(
      w * 0.88, h * 0.28,
      w * 1.02, h * 0.70,
      w * 0.76, h * 0.92,
    );
    // Bottom curve
    outerPath.cubicTo(
      w * 0.60, h * 1.02,
      w * 0.40, h * 1.02,
      w * 0.24, h * 0.92,
    );
    // Left flame curvature
    outerPath.cubicTo(
      -w * 0.02, h * 0.70,
      w * 0.12, h * 0.28,
      outerTipX, outerTipY,
    );
    outerPath.close();

    final outerGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFF3D00),
        Color(0xFFFF6600),
        Color(0xFFFF9100),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final outerPaint = Paint()
      ..shader = outerGradient
      ..style = PaintingStyle.fill;
    canvas.drawPath(outerPath, outerPaint);

    // 3. Inner Core Flame
    final innerPath = Path();
    final innerTipX = w * 0.50 + math.sin(flickerProgress * math.pi * 2 + 1) * 3;
    final innerTipY = h * 0.32;

    innerPath.moveTo(innerTipX, innerTipY);
    innerPath.cubicTo(
      w * 0.78, h * 0.48,
      w * 0.84, h * 0.76,
      w * 0.66, h * 0.90,
    );
    innerPath.cubicTo(
      w * 0.56, h * 0.96,
      w * 0.44, h * 0.96,
      w * 0.34, h * 0.90,
    );
    innerPath.cubicTo(
      w * 0.16, h * 0.76,
      w * 0.22, h * 0.48,
      innerTipX, innerTipY,
    );
    innerPath.close();

    final innerGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFFF9C4),
        Color(0xFFFFEA00),
        Color(0xFFFFC107),
      ],
    ).createShader(Rect.fromLTWH(0, h * 0.25, w, h * 0.75));

    final innerPaint = Paint()
      ..shader = innerGradient
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerPath, innerPaint);

    // 4. Cute Rosy Cheeks
    final cheekPaint = Paint()
      ..color = const Color(0xFFFF5252).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.32, h * 0.70), width: 14, height: 8),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.68, h * 0.70), width: 14, height: 8),
      cheekPaint,
    );

    // 5. Expressive Eyes
    final eyePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final specularPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final eyeY = h * 0.62;
    final leftEyeX = w * 0.38;
    final rightEyeX = w * 0.62;

    if (mood == MascotMood.celebrating) {
      // Happy curved closed eyes ^ ^
      final happyEyePaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      final leftArc = Path()
        ..moveTo(leftEyeX - 7, eyeY + 2)
        ..quadraticBezierTo(leftEyeX, eyeY - 6, leftEyeX + 7, eyeY + 2);
      final rightArc = Path()
        ..moveTo(rightEyeX - 7, eyeY + 2)
        ..quadraticBezierTo(rightEyeX, eyeY - 6, rightEyeX + 7, eyeY + 2);

      canvas.drawPath(leftArc, happyEyePaint);
      canvas.drawPath(rightArc, happyEyePaint);
    } else if (isBlinking) {
      // Blinking horizontal line
      final blinkPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(leftEyeX - 6, eyeY), Offset(leftEyeX + 6, eyeY), blinkPaint);
      canvas.drawLine(Offset(rightEyeX - 6, eyeY), Offset(rightEyeX + 6, eyeY), blinkPaint);
    } else {
      // Big expressive anime eyes
      double eyeOffsetY = 0;
      if (mood == MascotMood.typing) {
        eyeOffsetY = 3.0; // looking down at inputs
      } else if (mood == MascotMood.thinking) {
        eyeOffsetY = -2.0; // looking up curiously
      }

      // Left Eye
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(leftEyeX, eyeY + eyeOffsetY), width: 10, height: 14),
          const Radius.circular(5),
        ),
        eyePaint,
      );
      // Left Specular Glint (Top Sparkle)
      canvas.drawCircle(Offset(leftEyeX - 2, eyeY - 3 + eyeOffsetY), 2.8, specularPaint);
      // Left Specular Glint (Bottom small)
      canvas.drawCircle(Offset(leftEyeX + 2, eyeY + 2 + eyeOffsetY), 1.4, specularPaint);

      // Right Eye
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(rightEyeX, eyeY + eyeOffsetY), width: 10, height: 14),
          const Radius.circular(5),
        ),
        eyePaint,
      );
      // Right Specular Glint
      canvas.drawCircle(Offset(rightEyeX - 2, eyeY - 3 + eyeOffsetY), 2.8, specularPaint);
      canvas.drawCircle(Offset(rightEyeX + 2, eyeY + 2 + eyeOffsetY), 1.4, specularPaint);
    }

    // 6. Cute Smile / Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final mouthY = h * 0.74;
    final mouthPath = Path();

    if (mood == MascotMood.celebrating) {
      // Open joyful mouth (D shape)
      final joyfulMouth = Path()
        ..moveTo(w * 0.42, mouthY - 2)
        ..quadraticBezierTo(w * 0.50, mouthY + 9, w * 0.58, mouthY - 2)
        ..close();
      final mouthFill = Paint()..color = const Color(0xFF881337);
      canvas.drawPath(joyfulMouth, mouthFill);
      canvas.drawPath(joyfulMouth, mouthPaint);
    } else if (mood == MascotMood.error) {
      // Puzzled slightly wavy mouth
      mouthPath.moveTo(w * 0.44, mouthY + 2);
      mouthPath.quadraticBezierTo(w * 0.50, mouthY - 3, w * 0.56, mouthY + 2);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      // Cheerful natural smile
      mouthPath.moveTo(w * 0.44, mouthY);
      mouthPath.quadraticBezierTo(w * 0.50, mouthY + 5, w * 0.56, mouthY);
      canvas.drawPath(mouthPath, mouthPaint);
    }

    // 7. Floating Sparkles / Magic Stars
    _drawSparkle(canvas, Offset(w * 0.14, h * 0.35), 6.0, flickerProgress);
    _drawSparkle(canvas, Offset(w * 0.88, h * 0.42), 4.5, 1.0 - flickerProgress);
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, double progress) {
    final sparklePaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.5 + progress * 0.5)
      ..style = PaintingStyle.fill;

    final currentSize = size * (0.8 + progress * 0.4);
    final path = Path()
      ..moveTo(center.dx, center.dy - currentSize)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + currentSize, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + currentSize)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - currentSize, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - currentSize)
      ..close();

    canvas.drawPath(path, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant _FlamePainter oldDelegate) {
    return oldDelegate.flickerProgress != flickerProgress ||
        oldDelegate.flickerScale != flickerScale ||
        oldDelegate.isBlinking != isBlinking ||
        oldDelegate.mood != mood;
  }
}
