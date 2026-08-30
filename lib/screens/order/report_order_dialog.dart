import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/order_provider.dart';

class ReportOrderDialog extends StatefulWidget {
  final String orderId;
  final String orderNumber;

  const ReportOrderDialog({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  State<ReportOrderDialog> createState() => _ReportOrderDialogState();
}

class _ReportOrderDialogState extends State<ReportOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'LEAKAGE';
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'LEAKAGE',
      'title': 'Gas Leakage / Safety Concern',
      'icon': Icons.warning_amber_rounded,
      'color': Colors.red,
    },
    {
      'id': 'BROKEN_SEAL',
      'title': 'Broken or Tampered Safety Seal',
      'icon': Icons.gpp_bad_outlined,
      'color': Colors.orange,
    },
    {
      'id': 'WRONG_WEIGHT',
      'title': 'Underweight / Inaccurate Quantity',
      'icon': Icons.scale_outlined,
      'color': Colors.amber,
    },
    {
      'id': 'DELAYED_DELIVERY',
      'title': 'Significant Delivery Delay',
      'icon': Icons.access_time_filled_outlined,
      'color': Colors.blue,
    },
    {
      'id': 'OVERCHARGED',
      'title': 'Overcharged / Price Discrepancy',
      'icon': Icons.monetization_on_outlined,
      'color': Colors.purple,
    },
    {
      'id': 'RIDER_ISSUE',
      'title': 'Rider Conduct or Delivery Issue',
      'icon': Icons.two_wheeler_outlined,
      'color': Colors.teal,
    },
    {
      'id': 'OTHER',
      'title': 'Other General Issue',
      'icon': Icons.help_outline_rounded,
      'color': Colors.grey,
    },
  ];

  @override
  void initState() {
    super.initState();
    _subjectController.text = 'Issue with Order #${widget.orderNumber}';
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final orderProvider = context.read<OrderProvider>();

    final success = await orderProvider.reportIssue(
      orderId: widget.orderId,
      category: _selectedCategory,
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support ticket created. Our team will contact you shortly.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? 'Failed to submit report. Please try again.'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.report_problem_rounded, color: Colors.red, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report Order Issue',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Order #${widget.orderNumber}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Issue Category',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
                    ),
                  ),
                  items: _categories.map((c) {
                    return DropdownMenuItem<String>(
                      value: c['id'] as String,
                      child: Row(
                        children: [
                          Icon(c['icon'] as IconData, size: 18, color: c['color'] as Color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c['title'] as String,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  'Subject',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    hintText: 'Brief summary of problem',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a subject' : null,
                ),
                const SizedBox(height: 14),
                Text(
                  'Description & Details',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Please describe the problem in detail (e.g. cylinder condition, leak location, weight discrepancy)...',
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null || v.trim().length < 5
                      ? 'Please provide at least 5 characters of description'
                      : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Submit Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
