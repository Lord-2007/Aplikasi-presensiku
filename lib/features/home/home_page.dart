import 'dart:async';
import '../core_imports.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _now = DateTime.now();
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(
        const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _info(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Widget _box(String label, String val, Color c) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration:
              BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: kMuted, fontSize: 11)),
            Text(val,
                style: TextStyle(color: c, fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
        ),
      );

  Widget _action(String label, IconData icon, Color c, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 100,
            decoration:
                BoxDecoration(color: c, borderRadius: BorderRadius.circular(18)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([AppState.clockIn, AppState.clockOut]),
        builder: (_, __) {
          final ci = AppState.clockIn.value, co = AppState.clockOut.value;
          return Column(children: [
            const AppHeader(AppState.nama, '${AppState.jabatan} • NIP: ${AppState.nip}',
                trailing: StatusBadge('Aktif', Colors.white)),
            Expanded(
              child: ListView(padding: const EdgeInsets.all(16), children: [
                AppCard(
                  child: Column(children: [
                    Text(tgl(_now), style: const TextStyle(color: kMuted)),
                    Text(hms(_now),
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
                    const StatusBadge('Shift Reguler · 08:00–17:00 WIB', kPrimary),
                    const SizedBox(height: 14),
                    Row(children: [
                      _box('Jam Masuk', ci == null ? '--:--' : hm(ci), kGreen),
                      const SizedBox(width: 10),
                      _box('Jam Pulang', co == null ? '--:--' : hm(co), kRed),
                    ]),
                  ]),
                ),
                Row(children: [
                  _action('CLOCK IN', Icons.fingerprint, kGreen, () {
                    if (ci != null) return _info('Anda sudah Clock In hari ini');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ClockInPage()));
                  }),
                  const SizedBox(width: 12),
                  _action('CLOCK OUT', Icons.logout, kRed, () {
                    if (ci == null) return _info('Lakukan Clock In terlebih dahulu');
                    if (co != null) return _info('Anda sudah Clock Out hari ini');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ClockOutPage()));
                  }),
                ]),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Aktivitas Presensi Terakhir',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.how_to_reg, color: kGreen),
                      title: const Text('Hari ini'),
                      subtitle: const Text(AppState.lokasi),
                      trailing: Text(
                          '${ci == null ? '--:--' : hm(ci)} – ${co == null ? '--:--' : hm(co)}'),
                    ),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.how_to_reg, color: kYellow),
                      title: Text('Minggu, 4 Okt'),
                      subtitle: Text('Terlambat 12 menit'),
                      trailing: Text('08:12 – 17:05'),
                    ),
                  ]),
                ),
              ]),
            ),
          ]);
        },
      );
}
