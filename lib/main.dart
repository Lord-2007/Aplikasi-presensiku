import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/app_state.dart';
import 'features/splash/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppState.init();
  } catch (e, stack) {
    debugPrint('Inisialisasi AppState gagal: $e\n$stack');
  }
  runApp(const PresensiKuApp());
}

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
