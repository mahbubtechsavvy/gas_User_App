import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_button.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _category = 'GENERAL';

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = context.read<ProfileProvider>();
    final loc = context.read<LocaleProvider>();

    final success = await profile.submitSupportTicket(
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      category: _category,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.isBangla ? 'আপনার মেসেজটি সফলভাবে পাঠানো হয়েছে!' : 'Support request submitted successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
      _subjectController.clear();
      _messageController.clear();
    } else if (profile.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(profile.error!), backgroundColor: AppTheme.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('support')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Direct Contact Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.headset_mic, color: AppTheme.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.isBangla ? 'জরুরি কাস্টমার হেল্পলাইন' : 'Customer Support Helpline',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '+880 1700-000000 (9 AM - 10 PM)',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.call, color: AppTheme.primary),
                      onPressed: () => launchUrl(Uri.parse('tel:+8801700000000')),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Account Recovery Box (BR-006)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD1B3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_reset, color: AppTheme.accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        loc.tr('accountRecovery'),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loc.isBangla
                        ? 'আপনি যদি ইমেইল অ্যাকাউন্টের অ্যাক্সেস হারিয়ে থাকেন, তবে পূর্ববর্তী অর্ডারের তথ্য ও মোবাইল নম্বর যাচাইয়ের মাধ্যমে সাপোর্ট টিম আপনার অ্যাকাউন্ট পুনরুদ্ধার করতে সহায়তা করবে।'
                        : 'If you lost access to your registered email, contact our support team with your phone number and recent order history for identity verification.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF993D00)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Support Ticket Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isBangla ? 'মেসেজ পাঠান' : 'Send a Message',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: const [
                          DropdownMenuItem(value: 'GENERAL', child: Text('General Inquiry')),
                          DropdownMenuItem(value: 'ORDER_ISSUE', child: Text('Order Issue / Delay')),
                          DropdownMenuItem(value: 'CYLINDER_RETURN', child: Text('Cylinder Deposit / Return')),
                          DropdownMenuItem(value: 'ACCOUNT_RECOVERY', child: Text('Account Recovery')),
                        ],
                        onChanged: (val) => setState(() => _category = val!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _subjectController,
                        decoration: const InputDecoration(labelText: 'Subject'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Message / Details'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: loc.isBangla ? 'মেসেজ পাঠান' : 'Submit Ticket',
                        isLoading: profile.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
