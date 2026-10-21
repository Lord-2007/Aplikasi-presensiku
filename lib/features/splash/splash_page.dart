import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../auth/login_page.dart';

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
    _timer = Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginPage()));
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
              child: const Column(mainAxisSize: MainAxisSize.min, children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.fingerprint, size: 56, color: kPrimary),
                ),
                SizedBox(height: 20),
                Text('PresensiKu',
                    style: TextStyle(
                        color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text('Presensi Karyawan Berbasis Lokasi & Biometrik',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ),
          ),
        ),
      );
}
