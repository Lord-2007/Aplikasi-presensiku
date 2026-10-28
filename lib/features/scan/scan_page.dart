import 'package:mobile_scanner/mobile_scanner.dart';
import '../core_imports.dart';

/// Kode QR kantor harus diawali teks ini (contoh isi QR: PRESENSIKU-HQ-MENARA-TEKNO).
/// Nantinya validasi dilakukan oleh server.
const kQrPrefix = 'PRESENSIKU';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _ctrl = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;
  bool _isTorchOn = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _processBarcode(String value) async {
    if (_handled) return;

    final messenger = ScaffoldMessenger.of(context);
    void info(String m) => messenger.showSnackBar(SnackBar(content: Text(m)));

    if (!value.startsWith(kQrPrefix)) {
      info('QR Code tidak valid untuk presensi ($value)');
      return;
    }

    // QR valid:
    // belum Clock In -> Clock In; sudah Clock In -> Clock Out.
    final now = DateTime.now();
    if (AppState.clockIn.value == null) {
      _handled = true;
      await AppState.doClockIn(
        time: now,
        customLokasi: 'HQ Menara Tekno (Scan QR)',
        customKeterangan: 'Scan QR Presensi Valid',
      );
      if (!mounted) return;
      Navigator.pop(context);
      info('Clock In berhasil via QR Code pada ${hm(now)} WIB');
    } else if (AppState.clockOut.value == null) {
      _handled = true;
      await AppState.doClockOut(
        time: now,
        customLokasi: 'HQ Menara Tekno (Scan QR)',
      );
      if (!mounted) return;
      Navigator.pop(context);
      info('Clock Out berhasil via QR Code pada ${hm(now)} WIB');
    } else {
      info('Presensi hari ini sudah lengkap (Clock In & Clock Out sudah tercatat)');
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final value = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (value == null) return;
    _processBarcode(value);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          AppHeader(
            'Scan QR Presensi',
            'Arahkan kamera ke kode QR kantor',
            back: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isTorchOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                  ),
                  tooltip: 'Flashlight',
                  onPressed: () async {
                    await _ctrl.toggleTorch();
                    setState(() => _isTorchOn = !_isTorchOn);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                  tooltip: 'Ganti Kamera',
                  onPressed: () => _ctrl.switchCamera(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Container(
                height: 340,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _ctrl,
                      onDetect: _onDetect,
                      errorBuilder: (context, error) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.videocam_off, color: Colors.white70, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'Kamera tidak dapat diakses:\n${error.errorDetails?.message ?? error.toString()}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => LocationService.openAppSettings(),
                                icon: const Icon(Icons.settings, size: 18),
                                label: const Text('Buka Pengaturan Izin'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(color: kPrimary, width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const AppCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFE0E7FF),
                    child: Icon(Icons.apartment, color: kPrimary),
                  ),
                  title: Text('HQ Menara Tekno', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('Lobi Utama · Lantai 1 · Menara Sudirman'),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.qr_code_2, color: kPrimary),
                label: const Text('Simulasi Scan QR Presensi (Demo)'),
                onPressed: () => _processBarcode('PRESENSIKU-HQ-MENARA-TEKNO'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tips: Jaga kamera tetap stabil dan pastikan kode QR berada di dalam kotak pemindai.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kMuted, fontSize: 12),
              ),
            ]),
          ),
        ]),
      );
}
