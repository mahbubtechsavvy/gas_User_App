import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _label = 'HOME';
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _thanaController = TextEditingController();
  final _districtController = TextEditingController();
  final _divisionController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.fullName ?? '';
      _phoneController.text = user.phone ?? '';
    }
    _divisionController.text = 'Dhaka';
    _districtController.text = 'Dhaka';
    _thanaController.text = 'Gulshan';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _thanaController.dispose();
    _districtController.dispose();
    _divisionController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final addressProv = context.read<AddressProvider>();
    final success = await addressProv.addAddress(
      label: _label,
      recipientName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      division: _divisionController.text.trim(),
      district: _districtController.text.trim(),
      thana: _thanaController.text.trim(),
      fullAddress: _addressController.text.trim(),
      landmark: _landmarkController.text.trim().isNotEmpty ? _landmarkController.text.trim() : null,
      isDefault: _isDefault,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else if (addressProv.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(addressProv.error!), backgroundColor: AppTheme.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final addressProv = context.watch<AddressProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('addNewAddress')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Address Type / Label
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isBangla ? 'ঠিকানার ধরন' : 'Address Label',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: ['HOME', 'WORK', 'OTHER'].map((label) {
                          final isSelected = _label == label;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(label),
                              selected: isSelected,
                              selectedColor: AppTheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                if (selected) setState(() => _label = label);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Contact Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isBangla ? 'প্রাপকের তথ্য' : 'Recipient Info',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: loc.tr('fullNameLabel'),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: loc.tr('phoneLabel'),
                          prefixIcon: const Icon(Icons.phone_android),
                        ),
                        validator: (val) => val == null || val.trim().length < 11 ? loc.tr('invalidPhone') : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Location Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isBangla ? 'ঠিকানার বিবরণ' : 'Address Details',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'House / Road / Flat / Area',
                          hintText: 'e.g. Flat 4B, House 24, Road 11',
                          prefixIcon: Icon(Icons.home_outlined),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _landmarkController,
                        decoration: InputDecoration(
                          labelText: loc.isBangla ? 'নিকটবর্তী ল্যান্ডমার্ক (ঐচ্ছিক)' : 'Landmark (Optional)',
                          hintText: 'e.g. Near City Bank',
                          prefixIcon: const Icon(Icons.flag_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _thanaController,
                              decoration: const InputDecoration(labelText: 'Thana / Upazila'),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _districtController,
                              decoration: const InputDecoration(labelText: 'District'),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _divisionController,
                        decoration: const InputDecoration(labelText: 'Division'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: SwitchListTile(
                  title: Text(loc.isBangla ? 'ডিফল্ট ডেলিভারি ঠিকানা হিসেবে নির্ধারণ করুন' : 'Set as default delivery address'),
                  value: _isDefault,
                  onChanged: (val) => setState(() => _isDefault = val),
                ),
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: loc.tr('save'),
                isLoading: addressProv.isLoading,
                onPressed: _save,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
