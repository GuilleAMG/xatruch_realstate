// Utilidades responsive.
import 'package:flutter/material.dart';

/// Utilidades responsive para adaptar la UI a diferentes tamaños de pantalla.
extension ResponsiveUtils on BuildContext {
  bool get isSmallPhone => MediaQuery.of(this).size.width < 360;
  double scaledFontSize(double base) =>
      isSmallPhone ? (base * 0.85).roundToDouble() : base;
}
