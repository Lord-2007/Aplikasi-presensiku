import 'dart:async';
import '../core_imports.dart';

class ClockInPage extends StatefulWidget {
  const ClockInPage({super.key});
  @override
  State<ClockInPage> createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  bool _selfie = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _submitClockIn() async {
    setState(() => _isSubmitting = true);
    final now = DateTime.now();

    await AppState.doClockIn(time: now);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Clock In berhasil dicatat pada ${hm(now)} WIB!'),
        backgroundColor: kGreen,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          const AppHeader(
            'Konfirmasi Clock In',
            'Pastikan data presensi sudah benar',
            back: true,
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              AppCard(
                child: Column(children: [
                  Text(
                    hms(_currentTime),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: kPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(tgl(_currentTime), style: const TextStyle(color: kMuted)),
                  const Divider(height: 24),
                  const Row(
                    children: [
                      Icon(Icons.work_outline, color: kPrimary),
                      SizedBox(width: 10),
                      Text(
                        'Shift Reguler · 08:00–17:00 WIB',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: kGreen),
                      const SizedBox(width: 10),
                      Text(
                        '${AppState.lokasi} (Dalam Radius)',
                        style: const TextStyle(color: kMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ]),
              ),
              AppCard(
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Verifikasi Wajah (Selfie)',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    if (_selfie) const StatusBadge('Wajah Terverifikasi 98%', kGreen),
                  ]),
                  const SizedBox(height: 14),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _selfie ? const Color(0xFFE8F5E9) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selfie ? kGreen : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor:
                                  _selfie ? Colors.white : const Color(0xFFE0E7FF),
                              child: Icon(
                                _selfie ? Icons.verified_user : Icons.face,
                                size: 50,
                                color: _selfie ? kGreen : kPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selfie
                                  ? 'Foto selfie siap diverifikasi'
                                  : 'Arahkan kamera ke wajah Anda',
                              style: TextStyle(
                                color: _selfie ? kGreen : kMuted,
                                fontSize: 12,
                                fontWeight: _selfie ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        if (_selfie)
                          Positioned(
                            bottom: 8,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${AppState.nip} • ${hm(_currentTime)} WIB',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => setState(() => _selfie = true),
                    icon: Icon(
                      _selfie ? Icons.refresh : Icons.camera_alt_outlined,
                      color: kPrimary,
                    ),
                    label: Text(_selfie ? 'Ambil Ulang Selfie' : 'Ambil Foto Selfie'),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pastikan wajah terlihat jelas tanpa masker dan pencahayaan cukup.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kMuted, fontSize: 11),
                  ),
                ]),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: kGreen,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: (!_selfie || _isSubmitting) ? null : _submitClockIn,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.fingerprint),
                label: Text(
                  _isSubmitting ? 'Menyimpan Presensi...' : 'Konfirmasi Clock In',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ]),
          ),
        ]),
      );
}
