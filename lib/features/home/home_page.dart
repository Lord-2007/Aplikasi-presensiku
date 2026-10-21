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
      const Duration(seconds: 1),
      (_) {
        if (mounted) setState(() => _now = DateTime.now());
      },
    );
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
            const SizedBox(height: 4),
            Text(val,
                style: TextStyle(color: c, fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
        ),
      );

  Widget _action({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDone,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: Material(
          color: isDone ? Colors.grey.shade300 : color,
          borderRadius: BorderRadius.circular(18),
          elevation: isDone ? 0 : 2,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(isDone ? Icons.check_circle : icon,
                    color: isDone ? Colors.grey.shade600 : Colors.white, size: 30),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isDone ? Colors.grey.shade700 : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isDone)
                  Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ]),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          AppState.clockIn,
          AppState.clockOut,
          AppState.user,
          AppState.attendanceHistory,
        ]),
        builder: (_, __) {
          final ci = AppState.clockIn.value;
          final co = AppState.clockOut.value;
          final history = AppState.attendanceHistory.value;

          return Column(children: [
            AppHeader(
              AppState.nama,
              '${AppState.jabatan} • NIP: ${AppState.nip}',
              trailing: const StatusBadge('Aktif', Colors.white),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.all(16), children: [
                AppCard(
                  child: Column(children: [
                    Text(tgl(_now), style: const TextStyle(color: kMuted)),
                    const SizedBox(height: 4),
                    Text(hms(_now),
                        style: const TextStyle(
                            fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1)),
                    const SizedBox(height: 6),
                    const StatusBadge('Shift Reguler · 08:00–17:00 WIB', kPrimary),
                    const SizedBox(height: 16),
                    Row(children: [
                      _box('Jam Masuk', ci == null ? '--:--' : hm(ci), kGreen),
                      const SizedBox(width: 10),
                      _box('Jam Pulang', co == null ? '--:--' : hm(co), kRed),
                    ]),
                  ]),
                ),
                Row(children: [
                  _action(
                    label: 'CLOCK IN',
                    icon: Icons.fingerprint,
                    color: kGreen,
                    isDone: ci != null,
                    onTap: () {
                      if (ci != null) {
                        _info('Anda sudah Clock In hari ini pada ${hm(ci)}');
                        return;
                      }
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ClockInPage()));
                    },
                  ),
                  const SizedBox(width: 12),
                  _action(
                    label: 'CLOCK OUT',
                    icon: Icons.logout,
                    color: kRed,
                    isDone: co != null,
                    onTap: () {
                      if (ci == null) {
                        _info('Lakukan Clock In terlebih dahulu sebelum Clock Out');
                        return;
                      }
                      if (co != null) {
                        _info('Anda sudah Clock Out hari ini pada ${hm(co)}');
                        return;
                      }
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ClockOutPage()));
                    },
                  ),
                ]),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Aktivitas Presensi Terakhir',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text('${history.length} Catatan',
                              style: const TextStyle(color: kMuted, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (history.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text('Belum ada riwayat presensi',
                                style: TextStyle(color: kMuted)),
                          ),
                        )
                      else
                        ...history.take(4).map((rec) {
                          final isLate = rec.status == 'Terlambat';
                          final isCuti = rec.status == 'Cuti' || rec.status == 'Izin';
                          final color = isLate
                              ? kYellow
                              : (isCuti ? kPrimary : kGreen);

                          final timeStr = rec.clockIn != null
                              ? '${hm(rec.clockIn!)} – ${rec.clockOut != null ? hm(rec.clockOut!) : '--:--'}'
                              : '— → —';

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              isCuti ? Icons.event_busy : Icons.how_to_reg,
                              color: color,
                            ),
                            title: Text(
                              rec.date,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              rec.keterangan ?? rec.lokasi,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                StatusBadge(rec.status, color),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ]),
            ),
          ]);
        },
      );
}
