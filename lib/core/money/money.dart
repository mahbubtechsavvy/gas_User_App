import 'package:intl/intl.dart';

class Money {
  final int paisa;

  const Money(this.paisa);

  factory Money.fromPaisa(int paisa) => Money(paisa);

  factory Money.fromBdt(num bdt) => Money((bdt * 100).round());

  factory Money.zero() => const Money(0);

  double get inBdt => paisa / 100.0;

  Money operator +(Money other) => Money(paisa + other.paisa);
  Money operator -(Money other) => Money(paisa - other.paisa);
  Money operator *(num factor) => Money((paisa * factor).round());

  bool get isZero => paisa == 0;
  bool get isPositive => paisa > 0;
  bool get isNegative => paisa < 0;

  String format({bool includeSymbol = true, bool showDecimals = false}) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: includeSymbol ? '৳' : '',
      customPattern: includeSymbol ? '৳#,##0.00' : '#,##0.00',
      decimalDigits: showDecimals || (paisa % 100 != 0) ? 2 : 0,
    );
    return formatter.format(inBdt).trim();
  }

  String formatBangla({bool includeSymbol = true}) {
    // English number formatted first, then convert digits to Bengali
    final formatted = format(includeSymbol: false);
    final banglaDigits = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      final char = formatted[i];
      buffer.write(banglaDigits[char] ?? char);
    }
    return includeSymbol ? '৳${buffer.toString()}' : buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money && runtimeType == other.runtimeType && paisa == other.paisa;

  @override
  int get hashCode => paisa.hashCode;

  @override
  String toString() => format();
}
