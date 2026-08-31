import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../models/vendor_branch_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalogue_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/flame_mascot.dart';
import '../../widgets/money_text.dart';
import '../auth/email_entry_screen.dart';
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
  late String _activeImageUrl;

  @override
  void initState() {
    super.initState();
    _activeImageUrl = widget.product.displayImageUrl;

    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.defaultVariant ?? widget.product.variants.first;
    }

    final catalogue = context.read<CatalogueProvider>();
    VendorBranchModel? matchedBranch;
    try {
      matchedBranch = catalogue.branches.firstWhere((b) => b.vendorId == widget.product.vendorId);
    } catch (_) {
      matchedBranch = catalogue.branches.isNotEmpty ? catalogue.branches.first : null;
    }

    _branch = widget.preselectedBranch ??
        matchedBranch ??
        catalogue.selectedBranch ??
        VendorBranchModel(
          id: '',
          vendorId: widget.product.vendorId,
          vendorName: 'LPG Gas Vendor',
          branchName: 'Main Branch',
          phone: '01700000000',
          address: 'Dhaka',
          district: 'Dhaka',
          thana: 'Gulshan',
        );
  }

  Widget _buildProductImage(String url) {
    if (url.startsWith('data:image')) {
      try {
        final commaIdx = url.indexOf(',');
        final base64Str = commaIdx != -1 ? url.substring(commaIdx + 1) : url;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildFallbackIcon(),
        );
      } catch (_) {
        return _buildFallbackIcon();
      }
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: AppTheme.primary,
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
      );
    }

    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return const Center(
      child: Icon(
        Icons.propane_tank,
        size: 96,
        color: AppTheme.primary,
      ),
    );
  }

  void _showZoomDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: _buildProductImage(url),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginRequiredSheet(BuildContext context, LocaleProvider loc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(28.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 30,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            FlameMascot(
              mood: MascotMood.idle,
              size: 80,
              speechBubbleText: loc.isBangla ? 'স্বাগতম!' : 'Welcome!',
            ),
            const SizedBox(height: 16),
            Text(
              loc.isBangla ? 'লগইন প্রয়োজন' : 'Sign In Required',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              loc.isBangla
                  ? 'কার্টে পণ্য যোগ করতে এবং নিরাপদে সিলিন্ডার অর্ডার করতে আপনার একাউন্টে লগইন করুন।'
                  : 'Please sign in to add LPG cylinders to your cart and place orders.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: loc.isBangla ? 'লগইন বা রেজিস্টার করুন' : 'Sign In / Register',
              icon: Icons.login_rounded,
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EmailEntryScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                loc.isBangla ? 'পরে করব' : 'Maybe Later',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _addToCart() async {
    if (_selectedVariant == null) return;

    final auth = context.read<AuthProvider>();
    final loc = context.read<LocaleProvider>();

    if (!auth.isAuthenticated) {
      _showLoginRequiredSheet(context, loc);
      return;
    }

    final cart = context.read<CartProvider>();

    final success = await cart.addToCart(
      branch: _branch.id.isNotEmpty ? _branch : null,
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
    final allImages = widget.product.images.isNotEmpty
        ? widget.product.images
        : [_activeImageUrl];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Interactive Hero Image Container
            Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: GestureDetector(
                        onTap: () => _showZoomDialog(context, _activeImageUrl),
                        child: Hero(
                          tag: 'product_image_${widget.product.id}',
                          child: _buildProductImage(_activeImageUrl),
                        ),
                      ),
                    ),
                  ),

                  // Verified Genuine Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Color(0xFF10B981), size: 14),
                          SizedBox(width: 4),
                          Text(
                            '100% Genuine Sealed',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tap to zoom hint
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Tap to zoom',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Multiple Image Thumbnails (if any)
            if (allImages.length > 1) ...[
              Container(
                height: 70,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: allImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final imgUrl = allImages[index];
                    final isSelected = imgUrl == _activeImageUrl;
                    return GestureDetector(
                      onTap: () => setState(() => _activeImageUrl = imgUrl),
                      child: Container(
                        width: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : AppTheme.border,
                            width: isSelected ? 2 : 1,
                          ),
                          color: const Color(0xFFF8FAFC),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: _buildProductImage(imgUrl),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

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
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedVariant = v;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Supply Type Selector (Refill vs New Cylinder)
                  Text(
                    loc.isBangla ? 'প্যাকেজ ধরন' : 'Supply Type',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // Find refill variant if exists
                            final refill = widget.product.variants.firstWhere(
                              (v) => v.supplyType == SupplyType.refill,
                              orElse: () => widget.product.variants.first,
                            );
                            setState(() => _selectedVariant = refill);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: variant?.supplyType == SupplyType.refill
                                  ? AppTheme.primaryLight
                                  : AppTheme.surface,
                              border: Border.all(
                                color: variant?.supplyType == SupplyType.refill
                                    ? AppTheme.primary
                                    : AppTheme.border,
                                width: variant?.supplyType == SupplyType.refill ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.autorenew,
                                      size: 18,
                                      color: variant?.supplyType == SupplyType.refill
                                          ? AppTheme.primary
                                          : AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      loc.isBangla ? 'রিফিল সিলিন্ডার' : 'Refill Exchange',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: variant?.supplyType == SupplyType.refill
                                            ? AppTheme.primary
                                            : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.isBangla ? 'খালি বোতল ফেরত দিন' : 'Exchange empty cylinder',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // Find new cylinder variant if exists
                            final newCyl = widget.product.variants.firstWhere(
                              (v) => v.supplyType == SupplyType.newCylinder,
                              orElse: () => widget.product.variants.first,
                            );
                            setState(() => _selectedVariant = newCyl);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: variant?.supplyType == SupplyType.newCylinder
                                  ? AppTheme.primaryLight
                                  : AppTheme.surface,
                              border: Border.all(
                                color: variant?.supplyType == SupplyType.newCylinder
                                    ? AppTheme.primary
                                    : AppTheme.border,
                                width: variant?.supplyType == SupplyType.newCylinder ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.add_shopping_cart,
                                      size: 18,
                                      color: variant?.supplyType == SupplyType.newCylinder
                                          ? AppTheme.primary
                                          : AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      loc.isBangla ? 'নতুন সিলিন্ডার' : 'New Package',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: variant?.supplyType == SupplyType.newCylinder
                                            ? AppTheme.primary
                                            : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.isBangla ? 'গ্যাস + নতুন সিলিন্ডার' : 'Includes cylinder deposit',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Price Breakdown Card
                  const SizedBox(height: 24),
                  if (variant != null) ...[
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.border),
                      ),
                      color: AppTheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.isBangla ? 'গ্যাস মূল্য' : 'Gas Price',
                                  style: const TextStyle(color: AppTheme.textSecondary),
                                ),
                                MoneyText(
                                  money: variant.effectivePrice,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            if (variant.supplyType == SupplyType.newCylinder && variant.depositPaisa > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    loc.isBangla ? 'সিলিন্ডার জামানত (ফেরতযোগ্য)' : 'Cylinder Deposit (Refundable)',
                                    style: const TextStyle(color: AppTheme.textSecondary),
                                  ),
                                  MoneyText(
                                    money: variant.deposit,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                            const Divider(height: 24),
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
