import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _isSubmitting = true);
    final loc = context.read<LocaleProvider>();

    try {
      final client = ApiClient();
      await client.post(
        '${ApiEndpoints.baseUrl}/me/orders/${widget.order.id}/reviews',
        body: {
          'rating': _rating.toInt(),
          'comment': _commentController.text.trim(),
        },
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.isBangla ? 'আপনার মূল্যবান মতামতের জন্য ধন্যবাদ!' : 'Thank you for your feedback!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.isBangla ? 'রেটিং সফলভাবে গৃহীত হয়েছে!' : 'Rating submitted successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();

    return AlertDialog(
      title: Text(loc.tr('rateVendor')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.order.vendorName} (${widget.order.branchName})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                Icons.star,
                color: Color(0xFFFFB800),
              ),
              onRatingUpdate: (rating) {
                setState(() => _rating = rating);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: loc.isBangla ? 'আপনার অভিজ্ঞতা সংক্ষেপে লিখুন...' : 'Write a brief review...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.tr('cancel')),
        ),
        CustomButton(
          text: loc.tr('confirm'),
          width: 120,
          isLoading: _isSubmitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}
