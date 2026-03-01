import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData.dark(useMaterial3: true).copyWith(
      visualDensity: VisualDensity.standard,
    );
  }
}