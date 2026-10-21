import '../core_imports.dart';

class ClockOutPage extends StatelessWidget {
  const ClockOutPage({super.key});

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
            const Center(
                child: Text('Selesaikan Presensi?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
            Center(
                child: Text('Jam pulang akan tercatat pada ${hm(now)} dan tidak dapat diubah.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: kMuted, fontSize: 12))),
            const SizedBox(height: 16),
            AppCard(
              child: Column(children: [
                ListTile(
                    title: const Text('Clock In'),
                    trailing: Text(hm(ci),
                        style: const TextStyle(
                            color: kGreen, fontWeight: FontWeight.w700, fontSize: 18))),
                ListTile(
                    title: const Text('Durasi Kerja'),
                    trailing: Text('${d.inHours}j ${d.inMinutes % 60}m',
                        style: const TextStyle(
                            color: kPrimary, fontWeight: FontWeight.w700, fontSize: 18))),
                const ListTile(
                    leading: Icon(Icons.place_outlined),
                    title: Text('${AppState.lokasi} · Di dalam radius')),
              ]),
            ),
            const AppCard(
              color: Color(0xFFFEF9E7),
              child: Text('Sebelum pulang: pastikan pekerjaan sudah disimpan dan meja kerja dalam keadaan rapi.',
                  style: TextStyle(fontSize: 12)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: kRed, minimumSize: const Size.fromHeight(50)),
              onPressed: () {
                AppState.clockOut.value = now;
                Navigator.pop(context);
              },
              child: const Text('Ya, Clock Out Sekarang'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const ScanPage())),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Clock Out via Scan QR'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali Bekerja'),
            ),
          ]),
        ),
      ]),
    );
  }
}
