import '../core_imports.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  Widget _stat(String n, String l, Color c) => Expanded(
        child: AppCard(
          child: Column(children: [
            Text(n,
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800, color: c)),
            const SizedBox(height: 2),
            Text(l, style: const TextStyle(color: kMuted, fontSize: 12)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => Column(children: [
        AppHeader('Riwayat Presensi', bulanTahun(DateTime.now())),
        Expanded(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              AppState.attendanceHistory,
              AppState.clockIn,
              AppState.clockOut,
            ]),
            builder: (_, __) {
              final list = AppState.attendanceHistory.value;

              final hadirCount = list.where((r) => r.status == 'Hadir').length;
              final terlambatCount =
                  list.where((r) => r.status == 'Terlambat').length;
              final cutiCount =
                  list.where((r) => r.status == 'Cuti' || r.status == 'Izin').length;

              final todayStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

              return ListView(padding: const EdgeInsets.all(16), children: [
                Row(children: [
                  _stat('$hadirCount', 'Hadir', kGreen),
                  const SizedBox(width: 8),
                  _stat('$terlambatCount', 'Terlambat', kYellow),
                  const SizedBox(width: 8),
                  _stat('$cutiCount', 'Izin/Cuti', kPrimary),
                ]),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Daftar Kehadiran Bulan Ini',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${list.length} Hari Tercatat',
                            style: const TextStyle(color: kMuted, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (list.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Belum ada rekaman presensi bulan ini',
                              style: TextStyle(color: kMuted),
                            ),
                          ),
                        )
                      else
                        ...list.map((rec) {
                          final isToday = rec.date == todayStr;
                          final isLate = rec.status == 'Terlambat';
                          final isCuti = rec.status == 'Cuti' || rec.status == 'Izin';
                          final color = isLate
                              ? kYellow
                              : (isCuti ? kPrimary : kGreen);

                          final timeStr = rec.clockIn != null
                              ? '${hm(rec.clockIn!)} → ${rec.clockOut != null ? hm(rec.clockOut!) : '--:--'}'
                              : '— → —';

                          // Ekstrak hari dari yyyy-MM-dd
                          final parts = rec.date.split('-');
                          final dayDisplay = parts.length == 3 ? parts[2] : rec.date;

                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                  width: 0.8,
                                ),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? kPrimary.withValues(alpha: 0.1)
                                      : kBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  dayDisplay,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: isToday ? kPrimary : Colors.black87,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    timeStr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (isToday) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: kPrimary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'HARI INI',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Text(
                                rec.keterangan ?? (rec.clockIn != null ? 'Masuk → Pulang' : rec.lokasi),
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: StatusBadge(rec.status, color),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ]);
            },
          ),
        ),
      ]);
}
