import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../home/main_navigation_shell.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _thanaController = TextEditingController();
  final _districtController = TextEditingController();
  final _divisionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.fullName ?? '';
      _phoneController.text = user.phone ?? '';
    }
    _districtController.text = 'Dhaka';
    _divisionController.text = 'Dhaka';
    _thanaController.text = 'Gulshan';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _thanaController.dispose();
    _districtController.dispose();
    _divisionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final address = context.read<AddressProvider>();

    final profileSuccess = await auth.updateCustomerProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (!profileSuccess) {
      if (mounted && auth.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error!), backgroundColor: AppTheme.danger),
        );
      }
      return;
    }

    // Add initial address if entered
    if (_addressController.text.trim().isNotEmpty) {
      await address.addAddress(
        label: 'HOME',
        recipientName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        division: _divisionController.text.trim(),
        district: _districtController.text.trim(),
        thana: _thanaController.text.trim(),
        fullAddress: _addressController.text.trim(),
        isDefault: true,
      );
    }

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          loc.isBangla ? 'প্রোফাইল ও ডেলিভারি ঠিকানা' : 'Complete Your Profile',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Welcome Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFEDD5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6600),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person_pin_circle_outlined, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.isBangla ? 'এক ক্লিকে ডেলিভারি পেতে ঠিকানা যুক্ত করুন' : 'Setup Express Delivery',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFC2410C)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loc.isBangla
                                  ? 'আপনার নাম ও ঠিকানা দিয়ে অর্ডার প্রক্রিয়া সম্পন্ন করুন।'
                                  : 'Enter your details once for instant cylinder delivery.',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF9A3412)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card 1: Personal Details
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person_outline, color: Color(0xFFFF6600), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Personal Information',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(loc.tr('fullName'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: loc.isBangla ? 'আপনার নাম' : 'e.g. Mahbubur Rahman',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF6600), width: 1.5)),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 16),

                      Text(loc.tr('phoneLabel'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '017XXXXXXXX',
                          prefixText: '+88 ',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF6600), width: 1.5)),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your phone number' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card 2: Delivery Address
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: Color(0xFFFF6600), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Primary Delivery Address',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('District *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _districtController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  ),
                                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Thana / Area *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _thanaController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  ),
                                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text('House, Road, Apartment Details *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'e.g. House 14, Road 5, Block B, Niketan',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF6600), width: 1.5)),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your street address' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                CustomButton(
                  text: loc.isBangla ? 'সম্পন্ন করুন ও গ্যাস অর্ডার শুরু করুন' : 'Complete Setup & Start Ordering',
                  isLoading: auth.isLoading,
                  icon: Icons.check,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
