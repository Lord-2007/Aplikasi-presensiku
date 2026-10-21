import '../core_imports.dart';

/// Placeholder pemindai QR. Integrasi nyata: paket `mobile_scanner`.
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// QR berhasil terbaca, tanpa selfie:
  /// belum Clock In -> Clock In; sudah Clock In -> Clock Out.
  void _onScanned() {
    final messenger = ScaffoldMessenger.of(context);
    void info(String m) => messenger.showSnackBar(SnackBar(content: Text(m)));
    final now = DateTime.now();
    if (AppState.clockIn.value == null) {
      AppState.clockIn.value = now;
      Navigator.pop(context);
      info('Clock In berhasil via QR Code');
    } else if (AppState.clockOut.value == null) {
      AppState.clockOut.value = now;
      Navigator.pop(context);
      info('Clock Out berhasil via QR Code');
    } else {
      info('Presensi hari ini sudah lengkap');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          const AppHeader('Scan QR Presensi', 'Arahkan kamera ke kode QR kantor',
              back: true),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Container(
                height: 340,
                decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(children: [
                      Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: kPrimary, width: 3),
                              borderRadius: BorderRadius.circular(16))),
                      const Center(
                          child: Icon(Icons.qr_code_2, color: Colors.white, size: 110)),
                      AnimatedBuilder(
                        animation: _c,
                        builder: (_, __) => Positioned(
                            top: 10 + _c.value * 180,
                            left: 6,
                            right: 6,
                            child: Container(height: 2, color: kPrimary)),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const AppCard(
                  child: ListTile(
                      leading: Icon(Icons.apartment),
                      title: Text('HQ Menara Tekno'),
                      subtitle: Text('Lobi Utama · Lantai 1'))),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: kPrimary, minimumSize: const Size.fromHeight(50)),
                onPressed: _onScanned,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Simulasikan Scan Berhasil'),
              ),
              const SizedBox(height: 10),
              const Text('Tips: jaga kamera tetap stabil dan pastikan kode terlihat utuh.',
                  style: TextStyle(color: kMuted, fontSize: 12)),
            ]),
          ),
        ]),
      );
}
