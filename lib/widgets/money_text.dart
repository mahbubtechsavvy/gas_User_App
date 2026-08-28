import 'package:flutter/material.dart';
import '../core/money/money.dart';

class MoneyText extends StatelessWidget {
  final Money money;
  final TextStyle? style;
  final bool showDecimals;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;

  const MoneyText({
    super.key,
    required this.money,
    this.style,
    this.showDecimals = false,
    this.color,
    this.fontWeight,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );

    return Text(
      money.format(showDecimals: showDecimals),
      style: effectiveStyle,
    );
  }
}
