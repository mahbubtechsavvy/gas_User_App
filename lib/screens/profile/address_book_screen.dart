import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/address_model.dart';
import '../../providers/address_provider.dart';
import '../../widgets/custom_button.dart';
import 'address_form_screen.dart';

class AddressBookScreen extends StatelessWidget {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final addressProv = context.watch<AddressProvider>();
    final addresses = addressProv.addresses;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('myAddresses')),
      ),
      body: addresses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off_outlined, size: 64, color: AppTheme.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      loc.isBangla ? 'কোনো সংরক্ষিত ঠিকানা নেই' : 'No saved addresses yet',
                      style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: loc.tr('addNewAddress'),
                      icon: Icons.add_location_alt_outlined,
                      width: 220,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddressFormScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _buildAddressCard(context, address, addressProv, loc);
              },
            ),
      bottomNavigationBar: addresses.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF6600).withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                child: CustomButton(
                  text: loc.tr('addNewAddress'),
                  icon: Icons.add_location_alt_outlined,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddressFormScreen()),
                    );
                  },
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    AddressModel address,
    AddressProvider addressProv,
    LocaleProvider loc,
  ) {
    final isSelected = addressProv.selectedAddress?.id == address.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : AppTheme.border,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          addressProv.selectAddress(address);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          address.label,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            loc.isBangla ? 'ডিফল্ট' : 'Default',
                            style: const TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20, color: AppTheme.textMuted),
                    onSelected: (val) {
                      if (val == 'default') {
                        addressProv.setDefaultAddress(address.id);
                      } else if (val == 'delete') {
                        addressProv.deleteAddress(address.id);
                      }
                    },
                    itemBuilder: (ctx) => [
                      if (!address.isDefault)
                        PopupMenuItem(
                          value: 'default',
                          child: Text(loc.isBangla ? 'ডিফল্ট করুন' : 'Set as Default'),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          loc.isBangla ? 'মুছে ফেলুন' : 'Delete',
                          style: const TextStyle(color: AppTheme.danger),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${address.recipientName} (${address.phone})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                address.fullAddress,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              Text(
                '${address.thana}, ${address.district}, ${address.division}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
