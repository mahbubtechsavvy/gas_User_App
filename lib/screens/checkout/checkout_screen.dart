import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/delivery_slot_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/money_text.dart';
import '../profile/address_book_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _notesController = TextEditingController();
  final _trxIdController = TextEditingController();
  String _selectedMethod = 'COD'; // 'COD', 'BKASH', 'NAGAD', 'ROCKET', 'BANK'

  final Map<String, Map<String, String>> _mfsDetails = {
    'BKASH': {
      'title': 'bKash Personal / Merchant',
      'number': '01644274016',
      'type': 'Send Money / Payment',
      'instructions': 'Send the exact bill amount to this bKash number and enter TrxID below.',
    },
    'NAGAD': {
      'title': 'Nagad Personal / Merchant',
      'number': '01644274016',
      'type': 'Send Money',
      'instructions': 'Send the exact bill amount to this Nagad number and enter TrxID below.',
    },
    'ROCKET': {
      'title': 'Rocket Personal',
      'number': '01644274016-8',
      'type': 'Send Money',
      'instructions': 'Send money to this Rocket number and enter TrxID below.',
    },
    'BANK': {
      'title': 'City Bank Transfer',
      'number': '1102938475',
      'type': 'GT Group / Gas Lagba',
      'instructions': 'Transfer to City Bank A/C 1102938475 (GT Group) & enter Reference.',
    },
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = context.read<CartProvider>().cart;
      final checkout = context.read<CheckoutProvider>();
      for (var group in cart.groups) {
        checkout.fetchSlotsForBranch(group.branchId);
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _trxIdController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitCheckout() async {
    final addressProv = context.read<AddressProvider>();
    final cartProv = context.read<CartProvider>();
    final checkoutProv = context.read<CheckoutProvider>();
    final loc = context.read<LocaleProvider>();

    final address = addressProv.selectedAddress;
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.isBangla ? 'অনুগ্রহ করে ডেলিভারি ঠিকানা নির্বাচন করুন' : 'Please select a delivery address'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    String noteText = _notesController.text.trim();
    if (_selectedMethod != 'COD' && _trxIdController.text.trim().isNotEmpty) {
      final trxNote = 'Payment Method: $_selectedMethod | TrxID: ${_trxIdController.text.trim()}';
      noteText = noteText.isEmpty ? trxNote : '$noteText ($trxNote)';
    }

    checkoutProv.setNotes(noteText);
    checkoutProv.setPaymentMethod(_selectedMethod == 'COD' ? 'COD' : 'ONLINE');
    final branchIds = cartProv.cart.groups.map((g) => g.branchId).toList();

    final createdOrders = await checkoutProv.executeCheckout(
      addressId: address.id,
      branchIds: branchIds,
    );

    if (!mounted) return;

    if (createdOrders != null && createdOrders.isNotEmpty) {
      await cartProv.clearCart();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(orders: createdOrders),
        ),
        (route) => route.isFirst,
      );
    } else if (checkoutProv.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(checkoutProv.error!),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? color : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off,
              color: isSelected ? color : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final addressProv = context.watch<AddressProvider>();
    final cartProv = context.watch<CartProvider>();
    final checkoutProv = context.watch<CheckoutProvider>();
    final cart = cartProv.cart;
    final selectedAddress = addressProv.selectedAddress;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('checkoutTitle')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
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
                            const Icon(Icons.location_on, color: AppTheme.accent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              loc.tr('deliveryAddress'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddressBookScreen()),
                            );
                          },
                          child: Text(
                            loc.tr('changeAddress'),
                            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (selectedAddress != null) ...[
                      Text(
                        '${selectedAddress.recipientName} (${selectedAddress.phone})',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedAddress.fullAddress,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      Text(
                        '${selectedAddress.thana}, ${selectedAddress.district}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ] else ...[
                      Text(
                        loc.isBangla ? 'কোনো ঠিকানা সংরক্ষিত নেই' : 'No address selected',
                        style: const TextStyle(color: AppTheme.danger),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Per-Branch Delivery Mode Scheduling
            Text(
              loc.tr('deliveryMode'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            ...cart.groups.map((group) {
              final choice = checkoutProv.getChoiceForBranch(group.branchId);
              final slots = checkoutProv.getSlotsForBranch(group.branchId);

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.storefront, size: 18, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            group.branchName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: Center(child: Text(loc.tr('asapDelivery'))),
                              selected: choice.deliveryMode == 'ASAP',
                              selectedColor: AppTheme.primary,
                              labelStyle: TextStyle(
                                color: choice.deliveryMode == 'ASAP' ? Colors.white : AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              onSelected: (selected) {
                                if (selected) checkoutProv.setDeliveryMode(group.branchId, 'ASAP');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: Center(child: Text(loc.tr('scheduledDelivery'))),
                              selected: choice.deliveryMode == 'SCHEDULED',
                              selectedColor: AppTheme.primary,
                              labelStyle: TextStyle(
                                color: choice.deliveryMode == 'SCHEDULED' ? Colors.white : AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              onSelected: (selected) {
                                if (selected) checkoutProv.setDeliveryMode(group.branchId, 'SCHEDULED');
                              },
                            ),
                          ),
                        ],
                      ),
                      if (choice.deliveryMode == 'SCHEDULED') ...[
                        const SizedBox(height: 12),
                        Text(
                          loc.tr('selectSlot'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        if (slots.isEmpty)
                          Text(
                            loc.isBangla ? 'আজকের জন্য কোনো নির্ধারিত স্লট নেই' : 'No available slots for today',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          )
                        else
                          DropdownButtonFormField<DeliverySlotModel>(
                            initialValue: choice.selectedSlot ?? (slots.isNotEmpty ? slots.first : null),
                            isExpanded: true,
                            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            items: slots.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(s.formattedSlot, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (slot) {
                              if (slot != null) {
                                checkoutProv.setDeliverySlot(group.branchId, slot);
                              }
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Payment Method Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.tr('paymentMethod'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_outlined, size: 12, color: AppTheme.success),
                      SizedBox(width: 4),
                      Text('100% Secure', style: TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Payment Options Cards
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    _buildPaymentOption(
                      id: 'COD',
                      title: loc.tr('cod'),
                      subtitle: loc.isBangla ? 'সিলিন্ডার গ্রহণ করে নগদ টাকা দিন' : 'Pay in cash to the rider upon arrival',
                      icon: Icons.payments_outlined,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      id: 'BKASH',
                      title: 'bKash (বিকাশ)',
                      subtitle: 'Send Money / Merchant: 01644274016',
                      icon: Icons.account_balance_wallet_outlined,
                      color: const Color(0xFFE2136E),
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      id: 'NAGAD',
                      title: 'Nagad (নগদ)',
                      subtitle: 'Send Money: 01644274016',
                      icon: Icons.flash_on_rounded,
                      color: const Color(0xFFF7941D),
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      id: 'ROCKET',
                      title: 'Rocket (রকেট)',
                      subtitle: 'Send Money: 01644274016-8',
                      icon: Icons.rocket_launch_outlined,
                      color: const Color(0xFF8C3494),
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      id: 'BANK',
                      title: 'Bank Transfer (সিটি ব্যাংক)',
                      subtitle: 'A/C: 1102938475 | GT Group',
                      icon: Icons.account_balance_outlined,
                      color: Colors.blue.shade700,
                    ),
                  ],
                ),
              ),
            ),

            // If MFS/Bank selected, show details card
            if (_selectedMethod != 'COD' && _mfsDetails.containsKey(_selectedMethod)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _mfsDetails[_selectedMethod]!['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account / Number:',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                            ),
                            Text(
                              _mfsDetails[_selectedMethod]!['number']!,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _copyToClipboard(
                            _mfsDetails[_selectedMethod]!['number']!,
                            _mfsDetails[_selectedMethod]!['title']!,
                          ),
                          icon: const Icon(Icons.copy, size: 14),
                          label: const Text('Copy', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _mfsDetails[_selectedMethod]!['instructions']!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _trxIdController,
                      decoration: InputDecoration(
                        labelText: 'Transaction ID / Reference (Optional)',
                        hintText: 'e.g. 9J4K2L8X',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Special Delivery Notes
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: loc.isBangla ? 'ডেলিভারি নির্দেশিকা (ঐচ্ছিক)' : 'Delivery Instructions (Optional)',
                    hintText: loc.isBangla ? 'যেমন: লিফট বন্ধ থাকলে কল দিন' : 'e.g. Call before arrival, 3rd floor',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bill Breakdown
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.tr('subtotal'), style: const TextStyle(color: AppTheme.textSecondary)),
                        MoneyText(money: cart.subtotal, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (cart.depositTotalPaisa > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(loc.tr('cylinderDepositTotal'), style: const TextStyle(color: AppTheme.accent)),
                          MoneyText(
                            money: cart.depositTotal,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.accent),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.tr('totalDeliveryFee'), style: const TextStyle(color: AppTheme.textSecondary)),
                        MoneyText(money: cart.deliveryFeeTotal, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.tr('grandTotal'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        MoneyText(
                          money: cart.grandTotal,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: _selectedMethod == 'COD' ? loc.tr('placeOrder') : 'Place Order & Pay Online',
              isLoading: checkoutProv.isLoading,
              icon: Icons.lock_outline,
              onPressed: _submitCheckout,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
