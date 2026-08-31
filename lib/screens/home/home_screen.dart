import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../models/vendor_branch_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/brand_badge_chip.dart';
import '../../widgets/flame_mascot.dart';
import '../../widgets/gradient_promo_banner.dart';
import '../../widgets/luxe_product_card.dart';
import '../auth/email_entry_screen.dart';
import '../cart/cart_screen.dart';
import '../notifications/notifications_screen.dart';
import '../order/order_tracking_screen.dart';
import '../product/product_details_screen.dart';
import '../profile/address_book_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedBrand = 'All';

  final List<String> _brands = const [
    'All',
    'Bashundhara',
    'Beximco',
    'Omera',
    'Jamuna',
    'TotalEnergies',
    'BM Gas',
    'Petromax',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    final cat = context.read<CatalogueProvider>();
    final notif = context.read<NotificationProvider>();
    final order = context.read<OrderProvider>();

    await Future.wait([
      cat.fetchCategories(),
      cat.fetchBranches(),
      cat.fetchProducts(),
      notif.fetchUnreadCount(),
      order.fetchOrders(),
    ]);
  }

  void _showLoginRequired(BuildContext context, LocaleProvider loc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(28.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
              size: 72,
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
            ),
            const SizedBox(height: 8),
            Text(
              loc.isBangla
                  ? 'সিলিন্ডার কার্টে যোগ করতে অনুগ্রহ করে আপনার একাউন্টে সাইন ইন করুন।'
                  : 'Please sign in to add LPG cylinders to your cart and place orders.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EmailEntryScreen()),
                );
              },
              child: Text(loc.isBangla ? 'সাইন ইন / রেজিস্টার' : 'Sign In / Register'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _handleQuickAddToCart(ProductModel product, VendorBranchModel? branch) async {
    final auth = context.read<AuthProvider>();
    final loc = context.read<LocaleProvider>();
    final cart = context.read<CartProvider>();

    if (!auth.isAuthenticated) {
      _showLoginRequired(context, loc);
      return;
    }

    final variant = product.defaultVariant ?? (product.variants.isNotEmpty ? product.variants.first : null);
    if (variant == null) return;

    final success = await cart.addToCart(
      branch: branch != null && branch.id.isNotEmpty ? branch : null,
      product: product,
      variant: variant,
      quantity: 1,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ${loc.tr('addedToCart')}'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final addressProv = context.watch<AddressProvider>();
    final catalogue = context.watch<CatalogueProvider>();
    final notif = context.watch<NotificationProvider>();
    final orderProv = context.watch<OrderProvider>();

    final activeOrders = orderProv.activeOrders;
    final branches = addressProv.servingBranches.isNotEmpty
        ? addressProv.servingBranches
        : catalogue.branches;

    // Filter products by selected brand if not 'All'
    final filteredProducts = _selectedBrand == 'All'
        ? catalogue.products
        : catalogue.products.where((p) => p.brand.toLowerCase().contains(_selectedBrand.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        toolbarHeight: 68,
        title: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddressBookScreen()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on_rounded, size: 18, color: Color(0xFFFF6600)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            loc.tr('deliverTo'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                        ],
                      ),
                      Text(
                        addressProv.selectedAddress != null
                            ? '${addressProv.selectedAddress!.label}: ${addressProv.selectedAddress!.thana}, ${addressProv.selectedAddress!.district}'
                            : (loc.isBangla ? 'ঠিকানা বেছে নিন' : 'Select Delivery Location'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Dual Language Switcher Pill
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              loc.setLocale(loc.isBangla ? 'en' : 'bn');
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, size: 13, color: Color(0xFF0F172A)),
                  const SizedBox(width: 4),
                  Text(
                    loc.isBangla ? 'বাং' : 'EN',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Notification Bell
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
            icon: Badge(
              isLabelVisible: notif.unreadCount > 0,
              label: Text('${notif.unreadCount}'),
              child: const Icon(Icons.notifications_outlined, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFFFF6600),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 14, bottom: 90), // Bottom padding for floating navbar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Capsule
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Color(0xFFFF6600), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            loc.isBangla ? 'গ্যাস সিলিন্ডার, রেগুলেটর খুঁজুন...' : 'Search LPG cylinders, accessories...',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Active Orders Notification Banner (Live Tracking)
              if (activeOrders.isNotEmpty) ...[
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingScreen(orderId: activeOrders.first.id),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6600),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.isBangla
                                      ? 'অর্ডার #${activeOrders.first.orderNumber} ডেলিভারি হচ্ছে'
                                      : 'Order #${activeOrders.first.orderNumber} Out for Delivery',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  loc.isBangla ? 'ম্যাপে লাইভ ট্র্যাক করতে ট্যাপ করুন' : 'Tap for live GPS route & PIN',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Promotional Banner Carousel
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GradientPromoBanner(
                  title: loc.isBangla ? 'দ্রুত ও নিরাপদ গ্যাস ডেলিভারি' : 'Instant 30-Min Gas Delivery',
                  subtitle: loc.isBangla ? '১০০% গ্যাস সিলিন্ডার ও ভেরিফাইড সেফটি ভালভ' : '100% genuine sealed cylinders to your door',
                  discountTag: 'LPG EXPRESS',
                  ctaText: loc.isBangla ? 'অর্ডার করুন' : 'Order Now',
                  onCtaPressed: () {
                    if (catalogue.products.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsScreen(product: catalogue.products.first),
                        ),
                      );
                    }
                  },
                ),
              ),

              // Categories Horizontal Filter Chips
              if (catalogue.categories.isNotEmpty) ...[
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.tr('categories'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: catalogue.categories.length + 1,
                    itemBuilder: (context, index) {
                      final isAll = index == 0;
                      final category = isAll ? null : catalogue.categories[index - 1];
                      final isSelected = isAll
                          ? catalogue.selectedCategory == null
                          : catalogue.selectedCategory?.id == category?.id;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          catalogue.selectCategory(category);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            isAll ? (loc.isBangla ? 'সব ক্যাটাগরি' : 'All') : category!.localizedName(loc.locale),
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF1E293B),
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Verified LPG Brands Selector Row
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.isBangla ? 'জনপ্রিয় গ্যাস ব্র্যান্ডসমূহ' : 'Top LPG Brands',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (_selectedBrand != 'All')
                      GestureDetector(
                        onTap: () => setState(() => _selectedBrand = 'All'),
                        child: Text(
                          loc.isBangla ? 'রিসেট' : 'Reset',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF6600),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _brands.length,
                  itemBuilder: (context, index) {
                    final brand = _brands[index];
                    return BrandBadgeChip(
                      brandName: brand,
                      isSelected: _selectedBrand == brand,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedBrand = brand);
                      },
                    );
                  },
                ),
              ),

              // Available Gas Cylinders 2-Column Showcase Grid
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.isBangla ? 'গ্যাস সিলিন্ডার কালেকশন' : 'LPG Gas Cylinders',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (filteredProducts.isNotEmpty)
                      Text(
                        '${filteredProducts.length} ${loc.isBangla ? 'টি অপশন' : 'items'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (catalogue.isLoading && catalogue.products.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Color(0xFFFF6600)),
                  ),
                )
              else if (filteredProducts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.propane_tank_outlined, size: 54, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        Text(
                          loc.isBangla ? 'বর্তমানে কোনো গ্যাস সিলিন্ডার পাওয়া যায়নি' : 'No LPG cylinders found in this filter',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      VendorBranchModel? branch;
                      try {
                        branch = branches.firstWhere((b) => b.vendorId == product.vendorId);
                      } catch (_) {
                        branch = branches.isNotEmpty ? branches.first : null;
                      }

                      return LuxeProductCard(
                        product: product,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(
                                product: product,
                                preselectedBranch: branch,
                              ),
                            ),
                          );
                        },
                        onAddToCart: () => _handleQuickAddToCart(product, branch),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
