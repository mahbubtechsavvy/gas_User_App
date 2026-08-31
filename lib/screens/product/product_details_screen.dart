import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    } catch (_) {}

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
          return const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFFF6600)),
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
        Icons.propane_tank_rounded,
        size: 110,
        color: Color(0xFFFF6600),
      ),
    );
  }

  void _showZoomDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.92),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.8,
              maxScale: 4.0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildProductImage(url),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product.brand.toUpperCase(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20, color: Color(0xFF0F172A)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.isBangla ? 'লিংক কপি করা হয়েছে' : 'Product link copied!'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3D Perspective Hero Container with Ambient Glow
            Container(
              width: double.infinity,
              height: 270,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Subtle ambient radial glow behind cylinder
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF6600).withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: GestureDetector(
                        onTap: () => _showZoomDialog(context, _activeImageUrl),
                        child: Hero(
                          tag: 'product_img_${widget.product.id}',
                          child: _buildProductImage(_activeImageUrl),
                        ),
                      ),
                    ),
                  ),

                  // Verified 100% Genuine Sealed Badge
                  Positioned(
                    top: 14,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Color(0xFF10B981), size: 14),
                          SizedBox(width: 4),
                          Text(
                            '100% Genuine Sealed Valve',
                            style: TextStyle(
                              color: Color(0xFF065F46),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tap to zoom hint
                  Positioned(
                    bottom: 14,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => _showZoomDialog(context, _activeImageUrl),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Tap to zoom',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Image Thumbnails Gallery (if multiple)
            if (allImages.length > 1) ...[
              Container(
                height: 70,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                        width: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF6600) : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
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
                  // Title & Brand Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4ED),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFE2CC)),
                        ),
                        child: Text(
                          widget.product.brand,
                          style: const TextStyle(
                            color: Color(0xFFFF6600),
                            fontWeight: FontWeight.w800,
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
                        : 'Standard verified LPG gas cylinder with high-security safety valve and home delivery support.',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  // Supply Type Selector (Refill vs New Cylinder Package)
                  Text(
                    loc.isBangla ? 'প্যাকেজের ধরন নির্বাচন করুন' : 'Package Type',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            final refill = widget.product.variants.firstWhere(
                              (v) => v.supplyType == SupplyType.refill,
                              orElse: () => widget.product.variants.first,
                            );
                            setState(() => _selectedVariant = refill);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: variant?.supplyType == SupplyType.refill
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              border: Border.all(
                                color: variant?.supplyType == SupplyType.refill
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.autorenew_rounded,
                                      size: 18,
                                      color: variant?.supplyType == SupplyType.refill
                                          ? const Color(0xFFFF6600)
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      loc.isBangla ? 'রিফিল সিলিন্ডার' : 'Refill Exchange',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: variant?.supplyType == SupplyType.refill
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.isBangla ? 'খালি বোতল ফেরত দিন' : 'Empty bottle exchange',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: variant?.supplyType == SupplyType.refill
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            final newCyl = widget.product.variants.firstWhere(
                              (v) => v.supplyType == SupplyType.newCylinder,
                              orElse: () => widget.product.variants.first,
                            );
                            setState(() => _selectedVariant = newCyl);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: variant?.supplyType == SupplyType.newCylinder
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              border: Border.all(
                                color: variant?.supplyType == SupplyType.newCylinder
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.add_shopping_cart_rounded,
                                      size: 18,
                                      color: variant?.supplyType == SupplyType.newCylinder
                                          ? const Color(0xFFFF6600)
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      loc.isBangla ? 'নতুন সিলিন্ডার' : 'New Package',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: variant?.supplyType == SupplyType.newCylinder
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.isBangla ? 'গ্যাস + নতুন সিলিন্ডার' : 'Includes deposit',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: variant?.supplyType == SupplyType.newCylinder
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Price Breakdown Card
                  const SizedBox(height: 18),
                  if (variant != null) ...[
                    Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                loc.isBangla ? 'গ্যাস মূল্য' : 'Gas Price',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                              ),
                              MoneyText(
                                money: variant.effectivePrice,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
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
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                ),
                                MoneyText(
                                  money: variant.deposit,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Color(0xFFF1F5F9)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                loc.isBangla ? 'প্রতি সিলিন্ডার মোট' : 'Total per cylinder',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              MoneyText(
                                money: variant.totalPrice,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Color(0xFFFF6600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Quantity Selector
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.isBangla ? 'পরিমাণ (সিলিন্ডার)' : 'Quantity',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_rounded, size: 18),
                              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_rounded, size: 18),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 20,
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
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                    MoneyText(
                      money: variant.totalPrice * _quantity,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
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
