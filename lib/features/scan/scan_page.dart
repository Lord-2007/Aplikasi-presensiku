import '../core_imports.dart';

/// Pemindai QR Presensi Kantor
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat(reverse: true);

  bool _isProcessing = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// QR berhasil terbaca:
  /// belum Clock In -> Clock In; sudah Clock In -> Clock Out.
  Future<void> _onScanned() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final messenger = ScaffoldMessenger.of(context);
    void info(String m, Color bg) => messenger.showSnackBar(
          SnackBar(content: Text(m), backgroundColor: bg),
        );

    final now = DateTime.now();
    if (AppState.clockIn.value == null) {
      await AppState.doClockIn(
        time: now,
        customLokasi: 'HQ Menara Tekno - QR Lobi Utama',
      );
      if (!mounted) return;
      Navigator.pop(context);
      info('Clock In berhasil via QR Code (${hm(now)} WIB)', kGreen);
    } else if (AppState.clockOut.value == null) {
      await AppState.doClockOut(time: now);
      if (!mounted) return;
      Navigator.pop(context);
      info('Clock Out berhasil via QR Code (${hm(now)} WIB)', kGreen);
    } else {
      setState(() => _isProcessing = false);
      info('Presensi hari ini sudah lengkap (Masuk & Pulang)', kPrimary);
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
                    width: 220,
                    height: 220,
                    child: Stack(children: [
                      Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: kPrimary, width: 3),
                              borderRadius: BorderRadius.circular(16))),
                      const Center(
                          child: Icon(Icons.qr_code_2, color: Colors.white, size: 120)),
                      AnimatedBuilder(
                        animation: _c,
                        builder: (_, __) => Positioned(
                            top: 10 + _c.value * 200,
                            left: 6,
                            right: 6,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: kPrimary,
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimary.withValues(alpha: 0.8),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const AppCard(
                  child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFFE0E7FF),
                        child: Icon(Icons.apartment, color: kPrimary),
                      ),
                      title: Text('HQ Menara Tekno',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Lobi Utama · Lantai 1 · QR Code Aktif'))),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: kPrimary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    )),
                onPressed: _isProcessing ? null : _onScanned,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.qr_code_scanner),
                label: Text(
                  _isProcessing
                      ? 'Memproses Presensi...'
                      : (AppState.clockIn.value == null
                          ? 'Simulasi Scan: Clock In'
                          : 'Simulasi Scan: Clock Out'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tips: Jaga kamera tetap stabil dan pastikan seluruh frame QR code berada di dalam kotak pemindai.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kMuted, fontSize: 12),
              ),
            ]),
          ),
        ]),
      );
}
