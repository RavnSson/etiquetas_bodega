import 'package:flutter/material.dart';

class AppTheme {
  // Paleta RedSalud (aprox. desde logo + criterio clínico)
  static const Color _primary = Color(0xFF00A3B5); // turquesa
  static const Color _primaryHover = Color(0xFF008C9E);
  static const Color _success = Color(0xFFA4C639); // lima (solo acento)
  static const Color _error = Color(0xFFD64545);
  static const Color _warning = Color(0xFFF0A23B);

  static const Color _background = Color(0xFFF7F9FA);
  static const Color _surface = Color(0xFFFFFFFF);

  static const Color _border = Color(0xFFDDE3E8);
  static const Color _divider = Color(0xFFE6EBEF);

  static const Color _textPrimary = Color(0xFF1E2A32);
  static const Color _textSecondary = Color(0xFF5E6B73);
  static const Color _textHint = Color(0xFF8A96A0);

  /// Tema principal institucional (Light)
  static ThemeData redSaludLight() {
    final colorScheme = const ColorScheme.light(
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _success,
      onSecondary: Colors.white,
      error: _error,
      onError: Colors.white,
      surface: _surface,
      onSurface: _textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _background,

      // Desktop feel: no tan "gordo" como mobile
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

      // Tipografía (deja default del sistema; se ve bien en Windows)
      textTheme: const TextTheme().apply(
        bodyColor: _textPrimary,
        displayColor: _textPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
      ),

      dividerTheme: const DividerThemeData(
        color: _divider,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        hintStyle: const TextStyle(color: _textHint),
        labelStyle: const TextStyle(color: _textSecondary),
        prefixIconColor: _textSecondary,
        suffixIconColor: _textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _error, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _border,
              disabledForegroundColor: _textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.pressed)) {
                  return _primaryHover.withValues(alpha: 0.12);
                }
                return null;
              }),
            ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          side: const BorderSide(color: _primary, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: _border, width: 1.2),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return _surface;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: _textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: _success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      // Útil para tablas/listas (las afinamos después en el widget si hace falta)
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F7)),
        headingTextStyle: const TextStyle(
          color: _textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        dataTextStyle: const TextStyle(color: _textPrimary, fontSize: 13),
        dividerThickness: 1,
        horizontalMargin: 12,
        columnSpacing: 16,
      ),
    );
  }

  // Deja dark como opcional (debug / futuro)
  static ThemeData dark() {
    return ThemeData.dark(
      useMaterial3: true,
    ).copyWith(visualDensity: VisualDensity.standard);
  }

  // Exponer colores de estado si los necesitas en widgets (chips de online/offline)
  static Color get success => _success;
  static Color get warning => _warning;
  static Color get error => _error;
  static Color get primary => _primary;
  static Color get textSecondary => _textSecondary;
  static Color get border => _border;
}
