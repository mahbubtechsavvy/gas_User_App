import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../models/vendor_branch_model.dart';
import '../../providers/catalogue_provider.dart';
import '../../widgets/money_text.dart';
import '../product/product_details_screen.dart';

class VendorShopScreen extends StatefulWidget {
  final VendorBranchModel branch;

  const VendorShopScreen({super.key, required this.branch});

  @override
  State<VendorShopScreen> createState() => _VendorShopScreenState();
}

class _VendorShopScreenState extends State<VendorShopScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogueProvider>().fetchProducts(branchId: widget.branch.id);
    });
  }

  Future<void> _refresh() async {
    await context.read<CatalogueProvider>().fetchProducts(branchId: widget.branch.id);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final catalogue = context.watch<CatalogueProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.branch.displayName),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Branch Header Card
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.branch.vendorName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.branch.isOpen ? AppTheme.successLight : AppTheme.dangerLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.branch.isOpen ? loc.tr('openNow') : loc.tr('closed'),
                          style: TextStyle(
                            color: widget.branch.isOpen ? AppTheme.success : AppTheme.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.branch.branchName} • ${widget.branch.address}, ${widget.branch.thana}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFB800), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.branch.rating.toStringAsFixed(1)} (${widget.branch.totalRatings} ratings)',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.delivery_dining, color: AppTheme.primary, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${loc.tr('deliveryFee')}: ',
                            style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          ),
                          MoneyText(
                            money: widget.branch.deliveryFee,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                loc.isBangla ? 'উপলব্ধ গ্যাস সিলিন্ডার ও সামগ্রী' : 'Available LPG Cylinders',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            if (catalogue.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (catalogue.products.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        loc.isBangla
                            ? 'এই ব্রাঞ্চে বর্তমানে কোনো পণ্য তালিকাভুক্ত নেই'
                            : 'No products currently listed for this branch',
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
                itemCount: catalogue.products.length,
                itemBuilder: (context, index) {
                  final product = catalogue.products[index];
                  return _buildProductItem(context, product, loc);
                },
              ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildProductItem(BuildContext context, ProductModel product, LocaleProvider loc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(
                product: product,
                preselectedBranch: widget.branch,
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.propane_tank, color: AppTheme.primary, size: 36),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
                    Text(
                      '${product.brand} • ${product.variants.length} ${loc.isBangla ? 'টি অপশন' : 'options'}',
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
}
