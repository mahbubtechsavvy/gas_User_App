import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../models/vendor_branch_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalogue_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/money_text.dart';
import '../cart/cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  final VendorBranchModel? preselectedBranch;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.preselectedBranch,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  ProductVariantModel? _selectedVariant;
  int _quantity = 1;
  late VendorBranchModel _branch;

  @override
  void initState() {
    super.initState();
    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.defaultVariant ?? widget.product.variants.first;
    }

    final catalogue = context.read<CatalogueProvider>();
    _branch = widget.preselectedBranch ??
        catalogue.selectedBranch ??
        (catalogue.branches.isNotEmpty
            ? catalogue.branches.first
            : VendorBranchModel(
                id: 'br_default',
                vendorId: widget.product.vendorId,
                vendorName: 'LPG Gas Vendor',
                branchName: 'Main Branch',
                phone: '01700000000',
                address: 'Dhaka',
                district: 'Dhaka',
                thana: 'Gulshan',
              ));
  }

  void _addToCart() async {
    if (_selectedVariant == null) return;

    final cart = context.read<CartProvider>();
    final loc = context.read<LocaleProvider>();

    final success = await cart.addToCart(
      branch: _branch,
      product: widget.product,
      variant: _selectedVariant!,
      quantity: _quantity,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.tr('addedToCart')),
          backgroundColor: AppTheme.success,
          action: SnackBarAction(
            label: loc.tr('cart'),
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ),
      );
    } else if (cart.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cart.error!),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final cart = context.watch<CartProvider>();

    final variant = _selectedVariant;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Icon Hero Container
            Container(
              width: double.infinity,
              height: 200,
              color: AppTheme.primaryLight,
              child: const Center(
                child: Icon(
                  Icons.propane_tank,
                  size: 96,
                  color: AppTheme.primary,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Brand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.product.brand,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description.isNotEmpty
                        ? widget.product.description
                        : 'Standard verified LPG gas cylinder with high-security safety valve.',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Variant Selection (Cylinder Size)
                  if (widget.product.variants.length > 1) ...[
                    Text(
                      loc.isBangla ? 'সিলিন্ডারের সাইজ নির্বাচন করুন' : 'Select Cylinder Size',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.product.variants.map((v) {
                        final isSelected = v.id == _selectedVariant?.id;
                        return ChoiceChip(
                          label: Text(
                            '${v.name} (${v.cylinderSizeKg ?? 12} kg)',
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.primary,
                          backgroundColor: AppTheme.surface,
                          side: BorderSide(
                            color: isSelected ? AppTheme.primary : AppTheme.border,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedVariant = v);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Supply Type Notice & Pricing Breakdown
                  if (variant != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.tr('supplyType'),
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: variant.supplyType == SupplyType.newCylinder
                                        ? AppTheme.accentLight
                                        : AppTheme.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    variant.supplyType == SupplyType.newCylinder
                                        ? loc.tr('newCylinder')
                                        : loc.tr('refill'),
                                    style: TextStyle(
                                      color: variant.supplyType == SupplyType.newCylinder
                                          ? AppTheme.accent
                                          : AppTheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.isBangla ? 'গ্যাসের মূল্য' : 'Gas Refill Price',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                MoneyText(
                                  money: variant.effectivePrice,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                              ],
                            ),
                            if (variant.supplyType == SupplyType.newCylinder && variant.depositPaisa > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    loc.tr('cylinderDeposit'),
                                    style: const TextStyle(fontSize: 13, color: AppTheme.accent),
                                  ),
                                  MoneyText(
                                    money: variant.deposit,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                loc.tr('depositNotice'),
                                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.isBangla ? 'প্রতি সিলিন্ডার মোট' : 'Total per cylinder',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                MoneyText(
                                  money: variant.totalPrice,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Quantity Selector
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.isBangla ? 'পরিমাণ (সিলিন্ডার)' : 'Quantity',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (variant != null) ...[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.tr('grandTotal'),
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    MoneyText(
                      money: variant.totalPrice * _quantity,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
              ],
              Expanded(
                child: CustomButton(
                  text: loc.tr('addToCart'),
                  isLoading: cart.isLoading,
                  icon: Icons.shopping_cart_outlined,
                  onPressed: _addToCart,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
