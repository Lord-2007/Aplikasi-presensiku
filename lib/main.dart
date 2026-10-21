import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/splash/splash_page.dart';

void main() => runApp(const PresensiKuApp());

class PresensiKuApp extends StatelessWidget {
  const PresensiKuApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'PresensiKu',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: const SplashPage(),
      );
}
