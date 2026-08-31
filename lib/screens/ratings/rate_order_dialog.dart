import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';

class RateOrderDialog extends StatefulWidget {
  final OrderModel order;

  const RateOrderDialog({super.key, required this.order});

  @override
  State<RateOrderDialog> createState() => _RateOrderDialogState();
}

class _RateOrderDialogState extends State<RateOrderDialog> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  final Set<String> _selectedTags = {};

  final List<String> _positiveTagsEn = [
    '⚡ Super Fast Delivery',
    '🛡️ Intact Safety Seal',
    '🏍️ Polite & Helpful Rider',
    '⚖️ Accurate Weight',
    '💬 Great Communication',
  ];

  final List<String> _positiveTagsBn = [
    '⚡ খুব দ্রুত ডেলিভারি',
    '🛡️ আসল অক্ষত সিল',
    '🏍️ বিনয়ী রাইডার',
    '⚖️ সঠিক ওজন',
    '💬 চমৎকার সেবা',
  ];

  String _getRatingMood(double rating, bool isBn) {
    switch (rating.toInt()) {
      case 5:
        return isBn ? 'অসাধারণ অভিজ্ঞতা! 🌟' : 'Excellent Experience! 🌟';
      case 4:
        return isBn ? 'খুব ভালো! 👍' : 'Very Good! 👍';
      case 3:
        return isBn ? 'মোটামুটি 🙂' : 'Average 🙂';
      case 2:
        return isBn ? 'সন্তোষজনক নয় 😕' : 'Below Expectation 😕';
      default:
        return isBn ? 'অত্যন্ত খারাপ 😞' : 'Poor Experience 😞';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final loc = context.read<LocaleProvider>();
    final orderProvider = context.read<OrderProvider>();

    String finalComment = _commentController.text.trim();
    if (_selectedTags.isNotEmpty) {
      final tagsStr = _selectedTags.join(', ');
      finalComment = finalComment.isEmpty ? tagsStr : '$finalComment\n[$tagsStr]';
    }

    final success = await orderProvider.submitReview(
      orderId: widget.order.id,
      rating: _rating.toInt(),
      comment: finalComment.isNotEmpty ? finalComment : null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.isBangla ? 'আপনার মূল্যবান মতামতের জন্য ধন্যবাদ!' : 'Thank you for your review!'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? (loc.isBangla ? 'রেটিং জমা দিতে ব্যর্থ হয়েছে' : 'Failed to submit review')),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final isBn = loc.isBangla;
    final tags = isBn ? _positiveTagsBn : _positiveTagsEn;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 36),
              ),
              const SizedBox(height: 12),
              Text(
                isBn ? 'ডেলিভারি ও সেবা রেটিং দিন' : 'Rate Your Delivery & Order',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.order.vendorName} • #${widget.order.orderNumber}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFB800),
                ),
                onRatingUpdate: (rating) {
                  setState(() => _rating = rating);
                },
              ),
              const SizedBox(height: 8),
              Text(
                _getRatingMood(_rating, isBn),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isBn ? 'কি ভালো লেগেছে?' : 'What did you like?',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppTheme.textPrimary)),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isBn ? 'আপনার অতিরিক্ত অভিজ্ঞতা লিখুন...' : 'Add any additional feedback or comments...',
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(loc.tr('cancel')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: isBn ? 'জমা দিন' : 'Submit Review',
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
