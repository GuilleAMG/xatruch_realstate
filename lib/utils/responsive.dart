// Utilidades de diseño responsivo: breakpoints y constantes de espaciado
// que se adaptan según el tamaño del dispositivo.
import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 0;
  static const double tablet = 600; // ancho típico de tablet en píxeles lógicos
  static const double desktop = 1024; // preparado para escritorio
}

bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= Breakpoints.tablet;

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= Breakpoints.desktop;

/// Constantes auxiliares de espaciado que se adaptan al tamaño del dispositivo.
class Spacing {
  static double horizontal(BuildContext context) =>
      isTablet(context) ? 24.0 : 16.0;
  static double vertical(BuildContext context) =>
      isTablet(context) ? 20.0 : 12.0;
}
