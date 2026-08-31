import 'dart:math' as math;
import 'package:flutter/material.dart';

class AmbientGlowBackground extends StatefulWidget {
  final Widget child;
  final Color primaryGlow;
  final Color secondaryGlow;

  const AmbientGlowBackground({
    super.key,
    required this.child,
    this.primaryGlow = const Color(0xFFFF6600),
    this.secondaryGlow = const Color(0xFFFFB800),
  });

  @override
  State<AmbientGlowBackground> createState() => _AmbientGlowBackgroundState();
}

class _AmbientGlowBackgroundState extends State<AmbientGlowBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final shiftX1 = math.sin(t * math.pi * 2) * 30;
        final shiftY1 = math.cos(t * math.pi * 2) * 25;
        final shiftX2 = math.cos(t * math.pi * 2) * -35;
        final shiftY2 = math.sin(t * math.pi * 2) * -20;

        return Stack(
          children: [
            // Background Base Fill
            Container(color: const Color(0xFFF8FAFC)),

            // Ambient Glow Orb 1 (Top Left Warm Flame)
            Positioned(
              top: -60 + shiftY1,
              left: -40 + shiftX1,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.primaryGlow.withValues(alpha: 0.16),
                      widget.primaryGlow.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Ambient Glow Orb 2 (Top Right Golden Sunrise)
            Positioned(
              top: 40 + shiftY2,
              right: -50 + shiftX2,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.secondaryGlow.withValues(alpha: 0.18),
                      widget.secondaryGlow.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Ambient Glow Orb 3 (Subtle Center Core)
            Positioned(
              top: 180 + (shiftY1 * 0.5),
              left: (MediaQuery.of(context).size.width / 2) - 130,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.primaryGlow.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Foreground Content
            widget.child,
          ],
        );
      },
    );
  }
}
