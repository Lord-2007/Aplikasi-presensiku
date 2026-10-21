import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../main_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _nip = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;

  // Demo: akun dibuat admin HRD, tidak ada pendaftaran mandiri.
  static const _demoNip = '19940812';
  static const _demoPass = '123456';

  void _login() {
    if (!_form.currentState!.validate()) return;
    if (_nip.text == _demoNip && _pass.text == _demoPass) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainShell()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NIP atau kata sandi salah')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _form,
                child: Column(children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: kPrimary,
                    child: Icon(Icons.fingerprint, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text('Selamat Datang',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const Text('Masuk dengan akun karyawan Anda',
                      style: TextStyle(color: kMuted)),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _nip,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'NIP', prefixIcon: Icon(Icons.badge_outlined)),
                    validator: (v) => (v == null || v.isEmpty) ? 'NIP wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pass,
                    obscureText: _hide,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Kata sandi wajib diisi' : null,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: kPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      onPressed: _login,
                      child: const Text('Masuk'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Akun dibuat oleh admin HRD.\nHubungi HRD jika lupa kata sandi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  const Text('Demo: NIP 19940812 / Sandi 123456',
                      style: TextStyle(color: kPrimary, fontSize: 12)),
                ]),
              ),
            ),
          ),
        ),
      );
}
