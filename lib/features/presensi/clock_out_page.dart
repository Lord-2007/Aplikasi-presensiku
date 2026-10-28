import '../core_imports.dart';

class ClockOutPage extends StatefulWidget {
  const ClockOutPage({super.key});

  @override
  State<ClockOutPage> createState() => _ClockOutPageState();
}

class _ClockOutPageState extends State<ClockOutPage> {
  bool _isSubmitting = false;

  // Real GPS Location State
  bool _isLoadingLocation = true;
  OfficeLocationCheck? _locationCheck;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    setState(() => _isLoadingLocation = true);
    final result = await LocationService.checkLocationProximity();
    if (!mounted) return;
    setState(() {
      _locationCheck = result;
      _isLoadingLocation = false;
    });
  }

  Future<void> _submitClockOut() async {
    setState(() => _isSubmitting = true);
    final now = DateTime.now();

    String finalLokasi = LocationService.officeName;
    if (_locationCheck != null && _locationCheck!.isSuccess) {
      final pos = _locationCheck!.position;
      final distStr = _locationCheck!.distanceFormatted;
      if (_locationCheck!.isWithinRadius) {
        finalLokasi = '${LocationService.officeName} ($distStr)';
      } else {
        finalLokasi = 'Luar Kantor / WFH ($distStr)';
      }
      await AppState.doClockOut(
        time: now,
        customLokasi: finalLokasi,
        latitude: pos?.latitude,
        longitude: pos?.longitude,
      );
    } else {
      await AppState.doClockOut(time: now);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Clock Out berhasil dicatat pada ${hm(now)} WIB. Terima kasih atas kerja keras Anda!'),
        backgroundColor: kGreen,
        duration: const Duration(seconds: 3),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final ci = AppState.clockIn.value ?? now;
    final d = now.difference(ci);

    return Scaffold(
      body: Column(children: [
        const AppHeader('Konfirmasi Clock Out', 'Akhiri jam kerja hari ini', back: true),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            const SizedBox(height: 8),
            const Icon(Icons.logout, size: 56, color: kRed),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Selesaikan Presensi Hari Ini?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Jam pulang akan tercatat pada ${hm(now)} WIB dan tersimpan otomatis.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: kMuted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.login, color: kGreen),
                  title: const Text('Clock In'),
                  trailing: Text(
                    hm(ci),
                    style: const TextStyle(
                      color: kGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.timelapse, color: kPrimary),
                  title: const Text('Total Durasi Kerja'),
                  trailing: Text(
                    '${d.inHours}j ${d.inMinutes % 60}m',
                    style: const TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _locationCheck?.isWithinRadius == true ? Icons.place : Icons.place_outlined,
                    color: _locationCheck?.isWithinRadius == true ? kGreen : kMuted,
                  ),
                  title: Text(
                    _isLoadingLocation
                        ? 'Memeriksa GPS...'
                        : (_locationCheck != null && _locationCheck!.isSuccess
                            ? '${LocationService.officeName} · ${_locationCheck!.distanceFormatted}'
                            : '${AppState.lokasi} · GPS Manual'),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    _isLoadingLocation
                        ? 'Menghubungkan satelit lokasi...'
                        : (_locationCheck != null && _locationCheck!.isSuccess
                            ? (_locationCheck!.isWithinRadius ? 'Dalam radius kantor' : 'Di luar radius kantor (WFH)')
                            : (_locationCheck?.errorMessage ?? 'Layanan lokasi nonaktif')),
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh, size: 20, color: kPrimary),
                    tooltip: 'Perbarui Lokasi',
                    onPressed: _checkLocation,
                  ),
                ),
              ]),
            ),
            const AppCard(
              color: Color(0xFFFEF9E7),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates_outlined, color: kYellow),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pastikan seluruh pekerjaan penting telah disimpan dan perlengkapan kerja dalam keadaan aman.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: kRed,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isSubmitting ? null : _submitClockOut,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _isSubmitting ? 'Menyimpan...' : 'Ya, Clock Out Sekarang',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ScanPage()),
              ),
              icon: const Icon(Icons.qr_code_scanner, color: kPrimary),
              label: const Text('Clock Out via Scan QR'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali Bekerja', style: TextStyle(color: kMuted)),
            ),
          ]),
        ),
      ]),
    );
  }
}
