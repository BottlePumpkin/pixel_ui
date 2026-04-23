import 'package:flutter/material.dart';

import 'src/home_page.dart';
import 'src/theme.dart';

void main() {
  runApp(const TunerApp());
}

class TunerApp extends StatelessWidget {
  const TunerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pixel_ui Tuner',
      theme: pixelTunerTheme,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
