import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/app_state.dart';
import '../auth/login_page.dart';
import '../main_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
        ..forward();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      if (AppState.isLoggedIn) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainShell()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kPrimary,
        body: Center(
          child: FadeTransition(
            opacity: _c,
            child: ScaleTransition(
              scale: Tween(begin: .8, end: 1.0)
                  .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                const Text('PresensiKu',
                    style: TextStyle(
                        color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Presensi Karyawan Berbasis Lokasi & Biometrik',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ),
          ),
        ),
      );
}
