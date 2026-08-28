import 'package:flutter_test/flutter_test.dart';
import 'package:userapp/core/money/money.dart';

void main() {
  group('Money domain tests', () {
    test('converts paisa to BDT correctly', () {
      final m = Money.fromPaisa(125000);
      expect(m.inBdt, 1250.0);
      expect(m.paisa, 125000);
    });

    test('creates Money from BDT correctly', () {
      final m = Money.fromBdt(1450.50);
      expect(m.paisa, 145050);
    });

    test('performs safe integer arithmetic', () {
      final m1 = Money.fromPaisa(100000); // 1000 BDT
      final m2 = Money.fromPaisa(50000);  // 500 BDT
      final sum = m1 + m2;
      final diff = m1 - m2;
      final multiplied = m1 * 3;

      expect(sum.paisa, 150000);
      expect(diff.paisa, 50000);
      expect(multiplied.paisa, 300000);
    });

    test('formats English currency string accurately', () {
      final m = Money.fromPaisa(125000);
      expect(m.format(includeSymbol: true), '৳1,250');
      expect(m.format(includeSymbol: false), '1,250');
    });

    test('formats Bangla currency string accurately', () {
      final m = Money.fromPaisa(125000);
      expect(m.formatBangla(includeSymbol: true), '৳১,২৫০');
    });
  });
}
