import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _primaryColor = Color(0xFFFF3B30);
  static const _secondaryColor = Color(0xFFFF9500);

  static const _jua = TextStyle(fontFamily: 'Jua');
  static const _ibmPlexSansKR = TextStyle(fontFamily: 'IBMPlexSansKR');

  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    return base.copyWith(
      displayLarge: base.displayLarge?.merge(_ibmPlexSansKR),
      displayMedium: base.displayMedium?.merge(_ibmPlexSansKR),
      displaySmall: base.displaySmall?.merge(_ibmPlexSansKR),
      headlineLarge: base.headlineLarge?.merge(_jua),
      headlineMedium: base.headlineMedium?.merge(_jua),
      headlineSmall: base.headlineSmall?.merge(_jua),
      titleLarge: base.titleLarge?.merge(_jua),
      titleMedium: base.titleMedium?.merge(_jua),
      titleSmall: base.titleSmall?.merge(_ibmPlexSansKR),
      bodyLarge: base.bodyLarge?.merge(_ibmPlexSansKR),
      bodyMedium: base.bodyMedium?.merge(_ibmPlexSansKR),
      bodySmall: base.bodySmall?.merge(_ibmPlexSansKR),
      labelLarge: base.labelLarge?.merge(_ibmPlexSansKR),
      labelMedium: base.labelMedium?.merge(_ibmPlexSansKR),
      labelSmall: base.labelSmall?.merge(_ibmPlexSansKR),
    );
  }

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          secondary: _secondaryColor,
          brightness: Brightness.light,
        ),
        textTheme: _buildTextTheme(Brightness.light),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontFamily: 'Jua', fontSize: 16),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          secondary: _secondaryColor,
          brightness: Brightness.dark,
        ),
        textTheme: _buildTextTheme(Brightness.dark),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontFamily: 'Jua', fontSize: 16),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}
