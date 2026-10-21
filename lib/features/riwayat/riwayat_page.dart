import '../core_imports.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  Widget _stat(String n, String l, Color c) => Expanded(
        child: AppCard(
          child: Column(children: [
            Text(n, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: c)),
            Text(l, style: const TextStyle(color: kMuted, fontSize: 12)),
          ]),
        ),
      );

  Widget _row(String day, String time, String status, Color c) => ListTile(
        leading: Text(day, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        title: Text(time),
        subtitle: const Text('Masuk → Pulang', style: TextStyle(fontSize: 11)),
        trailing: StatusBadge(status, c),
      );

  @override
  Widget build(BuildContext context) => Column(children: [
        AppHeader('Riwayat Presensi', bulanTahun(DateTime.now())),
        Expanded(
          child: AnimatedBuilder(
            animation: Listenable.merge([AppState.clockIn, AppState.clockOut]),
            builder: (_, __) {
              final ci = AppState.clockIn.value, co = AppState.clockOut.value;
              return ListView(padding: const EdgeInsets.all(16), children: [
                Row(children: [
                  _stat('18', 'Hadir', kGreen),
                  _stat('2', 'Terlambat', kYellow),
                  _stat('1', 'Izin/Cuti', kPrimary),
                ]),
                AppCard(
                  child: Column(children: [
                    _row('${DateTime.now().day}',
                        '${ci == null ? '--:--' : hm(ci)} → ${co == null ? '--:--' : hm(co)}',
                        'Hari ini', kPrimary),
                    _row('4', '08:12 → 17:05', 'Terlambat', kYellow),
                    _row('3', '07:58 → 17:02', 'Hadir', kGreen),
                    _row('2', '— → —', 'Cuti', kPrimary),
                  ]),
                ),
              ]);
            },
          ),
        ),
      ]);
}
