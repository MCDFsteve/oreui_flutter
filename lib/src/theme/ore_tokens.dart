import 'package:flutter/widgets.dart';

@immutable
class OreTokens {
  const OreTokens._();

  static const double radius = 0;
  static const double borderWidth = 2;
  static const double focusWidth = 2;

  static const double controlHeightSm = 32;
  static const double controlHeightMd = 40;
  static const double controlHeightLg = 48;

  static const double gapXs = 4;
  static const double gapSm = 6;
  static const double gapMd = 10;
  static const double gapLg = 14;
  static const double gapXl = 20;

  static const EdgeInsets paddingSm = EdgeInsets.symmetric(horizontal: 10);
  static const EdgeInsets paddingMd = EdgeInsets.symmetric(horizontal: 14);
  static const EdgeInsets paddingLg = EdgeInsets.symmetric(horizontal: 18);

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration medium = Duration(milliseconds: 180);
  static const Duration slow = Duration(milliseconds: 240);
}
