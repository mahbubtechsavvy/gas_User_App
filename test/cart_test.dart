import 'package:flutter_test/flutter_test.dart';
import 'package:userapp/models/cart_model.dart';
import 'package:userapp/models/product_model.dart';

void main() {
  group('Cart & Multi-Vendor Grouping tests', () {
    test('groups items by vendor branch and calculates subtotals with deposits', () {
      final item1 = CartItemModel(
        id: 'ci_1',
        branchId: 'br_dhanmondi',
        branchName: 'Dhanmondi Branch',
        vendorName: 'Bashundhara LP Gas',
        productId: 'prod_1',
        productName: 'Bashundhara 12kg LP Gas',
        variantId: 'var_1',
        variantName: 'Refill 12kg',
        supplyType: SupplyType.refill,
        unitPricePaisa: 140000,
        depositPaisa: 0,
        quantity: 2,
      );

      final item2 = CartItemModel(
        id: 'ci_2',
        branchId: 'br_dhanmondi',
        branchName: 'Dhanmondi Branch',
        vendorName: 'Bashundhara LP Gas',
        productId: 'prod_2',
        productName: 'Bashundhara 12kg New Cylinder',
        variantId: 'var_2',
        variantName: 'New Cylinder 12kg',
        supplyType: SupplyType.newCylinder,
        unitPricePaisa: 140000,
        depositPaisa: 150000, // 1500 BDT refundable deposit
        quantity: 1,
      );

      final item3 = CartItemModel(
        id: 'ci_3',
        branchId: 'br_gulshan',
        branchName: 'Gulshan Branch',
        vendorName: 'Omera LPG',
        productId: 'prod_3',
        productName: 'Omera 35kg Commercial Cylinder',
        variantId: 'var_3',
        variantName: 'Refill 35kg',
        supplyType: SupplyType.refill,
        unitPricePaisa: 410000,
        depositPaisa: 0,
        quantity: 1,
      );

      final cart = CartModel.fromItems([item1, item2, item3]);

      expect(cart.groups.length, 2);
      expect(cart.totalItemsCount, 4);

      final dhanmondiGroup = cart.groups.firstWhere((g) => g.branchId == 'br_dhanmondi');
      expect(dhanmondiGroup.items.length, 2);
      expect(dhanmondiGroup.subtotalPaisa, 420000); // 1400*2 + 1400*1 = 4200 BDT
      expect(dhanmondiGroup.depositTotalPaisa, 150000); // 1500 BDT deposit
      expect(dhanmondiGroup.deliveryFeePaisa, 5000); // 50 BDT default delivery fee

      final gulshanGroup = cart.groups.firstWhere((g) => g.branchId == 'br_gulshan');
      expect(gulshanGroup.items.length, 1);
      expect(gulshanGroup.subtotalPaisa, 410000); // 4100 BDT
      expect(gulshanGroup.depositTotalPaisa, 0);

      // Grand totals across all branches
      expect(cart.subtotalPaisa, 830000); // 8300 BDT
      expect(cart.depositTotalPaisa, 150000); // 1500 BDT
      expect(cart.deliveryFeeTotalPaisa, 10000); // 50+50 = 100 BDT
      expect(cart.grandTotalPaisa, 990000); // 9900 BDT
    });
  });
}
