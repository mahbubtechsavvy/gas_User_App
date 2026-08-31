import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class BrandBadgeChip extends StatelessWidget {
  final String brandName;
  final String? logoUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const BrandBadgeChip({
    super.key,
    required this.brandName,
    this.logoUrl,
    required this.isSelected,
    required this.onTap,
  });

  Color _getBrandColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('bashundhara')) return const Color(0xFFE11D48);
    if (lower.contains('beximco')) return const Color(0xFF0284C7);
    if (lower.contains('omera')) return const Color(0xFFD97706);
    if (lower.contains('jamuna')) return const Color(0xFF059669);
    if (lower.contains('total')) return const Color(0xFFDC2626);
    if (lower.contains('bm')) return const Color(0xFF7C3AED);
    if (lower.contains('petromax')) return const Color(0xFFEA580C);
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = _getBrandColor(brandName);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6600) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6600) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFFF6600).withValues(alpha: 0.25)
                  : const Color(0xFF64748B).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : brandColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: brandColor.withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              brandName,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF334155),
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
