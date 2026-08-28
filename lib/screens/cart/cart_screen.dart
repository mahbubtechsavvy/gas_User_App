import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/cart_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/money_text.dart';
import '../auth/email_entry_screen.dart';
import '../checkout/checkout_screen.dart';
import '../home/main_navigation_shell.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final cartProv = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final cart = cartProv.cart;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(loc.tr('yourCart')),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(loc.isBangla ? 'কার্ট খালি করবেন?' : 'Clear Cart?'),
                    content: Text(
                      loc.isBangla
                          ? 'আপনি কি নিশ্চিত যে কার্টের সব পণ্য মুছে ফেলতে চান?'
                          : 'Are you sure you want to remove all items from your cart?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(loc.tr('cancel')),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          cartProv.clearCart();
                        },
                        child: Text(loc.isBangla ? 'মুছুন' : 'Clear', style: const TextStyle(color: AppTheme.danger)),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                loc.isBangla ? 'খালি করুন' : 'Clear',
                style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyStateView(
              icon: Icons.shopping_cart_outlined,
              title: loc.tr('emptyCart'),
              message: loc.tr('emptyCartSubtitle'),
              actionText: loc.isBangla ? 'সিলিন্ডার ব্রাউজ করুন' : 'Browse Gas Cylinders',
              onAction: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                  (route) => false,
                );
              },
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Multi-vendor guidance alert
                  if (cart.groups.length > 1)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCCE0FF)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              loc.tr('multiVendorNotice'),
                              style: const TextStyle(fontSize: 12, color: AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Branch Groups
                  ...cart.groups.map((group) => _buildBranchCartCard(context, group, cartProv, loc)),

                  const SizedBox(height: 16),

                  // Summary Bill Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.isBangla ? 'মূল্য বিবরণী' : 'Order Summary',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                loc.tr('grandTotal'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              MoneyText(
                                money: cart.grandTotal,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Checkout Button
                  CustomButton(
                    text: loc.tr('proceedToCheckout'),
                    icon: Icons.check_circle_outline,
                    onPressed: () {
                      if (!auth.isAuthenticated) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EmailEntryScreen()),
                        );
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildBranchCartCard(
    BuildContext context,
    BranchCartGroupModel group,
    CartProvider cartProv,
    LocaleProvider loc,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storefront, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${group.vendorName} (${group.branchName})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Text(
                  '${loc.tr('deliveryFee')}: ${group.deliveryFee.format()}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...group.items.map((item) => _buildCartItemTile(context, item, cartProv, loc)),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.tr('branchSubtotal'),
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                MoneyText(
                  money: group.subtotal + group.depositTotal,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemTile(
    BuildContext context,
    CartItemModel item,
    CartProvider cartProv,
    LocaleProvider loc,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.propane_tank, color: AppTheme.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.supplyType == SupplyType.newCylinder
                            ? AppTheme.accentLight
                            : AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.supplyType == SupplyType.newCylinder ? loc.tr('newCylinder') : loc.tr('refill'),
                        style: TextStyle(
                          color: item.supplyType == SupplyType.newCylinder
                              ? AppTheme.accent
                              : AppTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.variantName} ${item.cylinderSizeKg != null ? '(${item.cylinderSizeKg}kg)' : ''}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    MoneyText(
                      money: item.unitPrice + item.deposit,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary),
                    ),
                    if (item.depositPaisa > 0)
                      Text(
                        ' (Dep. ${item.deposit.format()})',
                        style: const TextStyle(fontSize: 11, color: AppTheme.accent),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  cartProv.updateQuantity(item.id, item.quantity - 1);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  cartProv.updateQuantity(item.id, item.quantity + 1);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.danger),
                padding: const EdgeInsets.only(left: 8),
                constraints: const BoxConstraints(),
                onPressed: () {
                  cartProv.removeItem(item.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
