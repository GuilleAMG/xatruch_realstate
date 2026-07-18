// Utilidades de diseño responsive.
import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 0;
  static const double tablet = 600; // ancho típico de tablet
  static const double desktop = 1024; // preparado para escritorio
}

bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= Breakpoints.tablet;

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= Breakpoints.desktop;

class Spacing {
  static double horizontal(BuildContext context) =>
      isTablet(context) ? 24.0 : 16.0;
  static double vertical(BuildContext context) =>
      isTablet(context) ? 20.0 : 12.0;
}
