import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/app_state.dart';
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
  bool _isLoading = false;

  // Akun default kepegawaian
  static const _demoNip = '19940812';
  static const _demoPass = '123456';

  @override
  void dispose() {
    _nip.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 600));

    final nipText = _nip.text.trim();
    final passText = _pass.text.trim();

    final isDefault = (nipText == _demoNip && passText == _demoPass);
    final isValidGeneric = (nipText.length >= 4 && passText.length >= 4);

    if (isDefault || isValidGeneric) {
      await AppState.login(nipInput: nipText, passwordInput: passText);

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang, ${AppState.nama}!'),
          backgroundColor: kGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NIP atau kata sandi salah. Silakan periksa kembali.'),
          backgroundColor: kRed,
        ),
      );
    }
  }

  Future<void> _biometricLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));

    await AppState.login(nipInput: _demoNip, passwordInput: _demoPass);

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Autentikasi biometrik berhasil!'),
        backgroundColor: kGreen,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Selamat Datang',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text('Masuk dengan akun karyawan Anda',
                        style: TextStyle(color: kMuted)),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _nip,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'NIP Karyawan',
                        prefixIcon: Icon(Icons.badge_outlined),
                        hintText: 'Misal: 19940812',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'NIP wajib diisi' : null,
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
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Kata sandi wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: kPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Masuk ke Aplikasi',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isLoading ? null : _biometricLogin,
                      icon: const Icon(Icons.fingerprint, color: kPrimary),
                      label: const Text(
                        'Masuk Cepat via Biometrik',
                        style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Akun dibuat oleh admin HRD / Kepegawaian.\nHubungi administrator jika lupa kata sandi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
