import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

final pixelTunerTheme = ThemeData(
  useMaterial3: false,
  scaffoldBackgroundColor: const Color(0xFFF5F1E8),
  primaryColor: const Color(0xFF5A8A3A),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF5A8A3A),
    secondary: Color(0xFFE07A3C),
    surface: Color(0xFFE8DFC6),
    error: Color(0xFFC94A4A),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF2A2A2A),
    onSurface: Color(0xFF2A2A2A),
    onError: Color(0xFFFFFFFF),
  ),
  textTheme: Typography.blackMountainView.apply(
    fontFamily: PixelText.mulmaruFontFamily,
    package: PixelText.mulmaruPackage,
  ),
  sliderTheme: const SliderThemeData(
    trackHeight: 4,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
    isDense: true,
  ),
  visualDensity: VisualDensity.compact,
);
