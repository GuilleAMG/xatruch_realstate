// Utilidades responsivas adicionales para adaptar la interfaz a distintos
// tamaños de pantalla, incluyendo detección de teléfonos pequeños.
import 'package:flutter/material.dart';

/// Utilidades responsivas para adaptar la UI a diferentes tamaños de pantalla.
extension ResponsiveUtils on BuildContext {
  /// Indica si el dispositivo tiene una pantalla angosta (teléfono pequeño, ancho < 360).
  bool get isSmallPhone => MediaQuery.of(this).size.width < 360;

  /// Retorna un tamaño de fuente escalado: reducido ~15% en teléfonos pequeños.
  double scaledFontSize(double base) =>
      isSmallPhone ? (base * 0.85).roundToDouble() : base;
}
