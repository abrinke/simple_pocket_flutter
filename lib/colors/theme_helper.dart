import 'package:flutter/material.dart';

class ThemeHelper {
  static Color inverseSurface(BuildContext context) {
    return Theme.of(context).colorScheme.inverseSurface;
  }
  static Color inversePrimary(BuildContext context) {
    return Theme.of(context).colorScheme.inversePrimary;
  }
  static Color primary(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color error(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }
}