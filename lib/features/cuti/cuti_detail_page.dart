import '../core_imports.dart';

class CutiDetailPage extends StatelessWidget {
  final String jenis, alasan;
  final DateTime mulai, selesai;
  final int hari;
  const CutiDetailPage(
      {super.key,
      required this.jenis,
      required this.mulai,
      required this.selesai,
      required this.alasan,
      required this.hari});

  Widget _step(String t, String s, Color c, bool done) => ListTile(
        leading: Icon(done ? Icons.check_circle : Icons.radio_button_checked, color: c),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(s),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          const AppHeader('Detail Pengajuan', 'REQ-CT-2026-1048', back: true),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              const AppCard(
                color: Color(0xFFFFF7E6),
                child: Column(children: [
                  Icon(Icons.schedule, color: kYellow, size: 36),
                  Text('MENUNGGU PERSETUJUAN',
                      style: TextStyle(color: kYellow, fontWeight: FontWeight.w800)),
                  Text('Pengajuan sedang ditinjau atasan. Estimasi respons maksimal 1 hari kerja.',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                ]),
              ),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(jenis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    StatusBadge('$hari hari', kPrimary),
                  ]),
                  const SizedBox(height: 8),
                  Text('Periode: ${mulai.day}/${mulai.month}/${mulai.year} – ${selesai.day}/${selesai.month}/${selesai.year}'),
                  Text('Alasan: $alasan'),
                  const Text('Penyetuju: Dwi Maharani · Engineering Manager'),
                ]),
              ),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Progres Pengajuan',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  _step('Pengajuan dikirim', 'Baru saja', kGreen, true),
                  _step('Review atasan', 'Sedang diproses', kPrimary, false),
                  _step('Keputusan akhir', 'Menunggu', kMuted, false),
                ]),
              ),
              OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Hubungi Atasan')),
              const SizedBox(height: 10),
              FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: kRed, minimumSize: const Size.fromHeight(48)),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Batalkan Pengajuan')),
            ]),
          ),
        ]),
      );
}
