import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../models/vendor_branch_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/money_text.dart';
import '../notifications/notifications_screen.dart';
import '../order/order_tracking_screen.dart';
import '../product/product_details_screen.dart';
import '../profile/address_book_screen.dart';
import '../search/search_screen.dart';
import '../vendor/vendor_shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        titleSpacing: 16,
        title: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddressBookScreen()),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppTheme.accent),
                  const SizedBox(width: 4),
                  Text(
                    loc.tr('deliverTo'),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.textMuted),
                ],
              ),
              Text(
                addressProv.selectedAddress != null
                    ? '${addressProv.selectedAddress!.label}: ${addressProv.selectedAddress!.thana}, ${addressProv.selectedAddress!.district}'
                    : loc.tr('selectAddress'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
            icon: Badge(
              isLabelVisible: notif.unreadCount > 0,
              label: Text('${notif.unreadCount}'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppTheme.textMuted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            loc.tr('search'),
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Active Orders Notification Banner
              if (activeOrders.isNotEmpty) ...[
                const SizedBox(height: 16),
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
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF003496), Color(0xFF0052CC)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.delivery_dining, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.isBangla
                                      ? 'আপনার অর্ডার (${activeOrders.first.orderNumber}) ডেলিভারির প্রক্রিয়ায় রয়েছে'
                                      : 'Order #${activeOrders.first.orderNumber} in progress',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  loc.isBangla ? 'লাইভ স্ট্যাটাস দেখতে ক্লিক করুন' : 'Tap to track live status',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Promotional Banner
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCCE0FF)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'LPG EXPRESS',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loc.isBangla ? 'নিরাপদ ও দ্রুত গ্যাস সিলিন্ডার' : 'Safe & Fast LPG Cylinders',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loc.isBangla ? 'বাসা ও রেস্টুরেন্টে হোম ডেলিভারি' : 'Reliable delivery to your doorstep',
                              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.propane_tank, size: 54, color: AppTheme.primary),
                    ],
                  ),
                ),
              ),

              // Categories Horizontal List
              if (catalogue.categories.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.tr('categories'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
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

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            isAll ? loc.tr('allCategories') : category!.localizedName(loc.locale),
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.primary,
                          backgroundColor: AppTheme.surface,
                          side: BorderSide(
                            color: isSelected ? AppTheme.primary : AppTheme.border,
                          ),
                          onSelected: (_) {
                            catalogue.selectCategory(category);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Serving Branches Section
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  loc.tr('nearbyVendors'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              if (catalogue.isLoading && branches.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (branches.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 48, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          loc.isBangla
                              ? 'আপনার নির্বাচিত এলাকায় কোনো ব্রাঞ্চ পাওয়া যায়নি'
                              : 'No gas branches currently serving this area',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: branches.length,
                  itemBuilder: (context, index) {
                    final branch = branches[index];
                    return _buildBranchCard(context, branch, loc);
                  },
                ),

              // Available Gas Cylinders & Products Section
              if (catalogue.products.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.isBangla ? 'গ্যাস সিলিন্ডার ও সামগ্রী' : 'Available Gas Cylinders',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${catalogue.products.length} ${loc.isBangla ? 'টি পণ্য' : 'items'}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: catalogue.products.length,
                  itemBuilder: (context, index) {
                    final product = catalogue.products[index];
                    return _buildHomeProductCard(context, product, loc, branches);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeProductCard(
    BuildContext context,
    ProductModel product,
    LocaleProvider loc,
    List<VendorBranchModel> branches,
  ) {
    VendorBranchModel? branch;
    try {
      branch = branches.firstWhere((b) => b.vendorId == product.vendorId);
    } catch (_) {
      branch = branches.isNotEmpty ? branches.first : null;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.propane_tank, color: AppTheme.primary, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${product.brand} • ${product.variants.length} ${loc.isBangla ? 'অপশন' : 'options'}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${loc.isBangla ? 'মূল্য ' : 'Price '} ',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        MoneyText(
                          money: product.minPrice,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchCard(BuildContext context, VendorBranchModel branch, LocaleProvider loc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.read<CatalogueProvider>().selectBranch(branch);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VendorShopScreen(branch: branch),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.store, color: AppTheme.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                branch.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: branch.isOpen ? AppTheme.successLight : AppTheme.dangerLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                branch.isOpen ? loc.tr('openNow') : loc.tr('closed'),
                                style: TextStyle(
                                  color: branch.isOpen ? AppTheme.success : AppTheme.danger,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${branch.address}, ${branch.thana}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFB800), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${branch.rating.toStringAsFixed(1)} (${branch.totalRatings})',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.delivery_dining, size: 16, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${loc.tr('deliveryFee')}: ',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                      MoneyText(
                        money: branch.deliveryFee,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  Text(
                    loc.tr('viewProducts'),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
