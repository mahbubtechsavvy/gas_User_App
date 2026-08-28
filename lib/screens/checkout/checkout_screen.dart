import 'package:flutter/material.dart';
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
    super.dispose();
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

    checkoutProv.setNotes(_notesController.text.trim());
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
            Text(
              loc.tr('paymentMethod'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.payments_outlined, color: AppTheme.primary),
                    title: Text(loc.tr('cod'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      loc.isBangla ? 'সিলিন্ডার গ্রহণ করে নগদ টাকা দিন' : 'Pay in cash when cylinders arrive at your door',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    trailing: Icon(
                      checkoutProv.paymentMethod == 'COD' ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: checkoutProv.paymentMethod == 'COD' ? AppTheme.primary : AppTheme.textMuted,
                    ),
                    onTap: () => checkoutProv.setPaymentMethod('COD'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.credit_card_outlined, color: AppTheme.primary),
                    title: Text(loc.tr('digitalPayment'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      loc.isBangla ? 'বিকাশ, নগদ, রকেট বা ব্যাংক কার্ড' : 'bKash, Nagad, Rocket, or Debit/Credit card',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    trailing: Icon(
                      checkoutProv.paymentMethod == 'ONLINE' ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: checkoutProv.paymentMethod == 'ONLINE' ? AppTheme.primary : AppTheme.textMuted,
                    ),
                    onTap: () => checkoutProv.setPaymentMethod('ONLINE'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Special Delivery Notes
            Card(
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
              text: loc.tr('placeOrder'),
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
