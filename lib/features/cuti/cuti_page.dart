import '../core_imports.dart';

class CutiPage extends StatefulWidget {
  const CutiPage({super.key});
  @override
  State<CutiPage> createState() => _CutiPageState();
}

class _CutiPageState extends State<CutiPage> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  String _jenis = 'Cuti Tahunan';
  DateTime _mulai = DateTime.now().add(const Duration(days: 3));
  DateTime _selesai = DateTime.now().add(const Duration(days: 4));
  final _alasan = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tab.dispose();
    _alasan.dispose();
    super.dispose();
  }

  Future<void> _pick(bool start) async {
    final d = await showDatePicker(
      context: context,
      initialDate: start ? _mulai : _selesai,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null) return;
    setState(() {
      if (start) {
        _mulai = d;
        if (_selesai.isBefore(d)) _selesai = d;
      } else {
        _selesai = d.isBefore(_mulai) ? _mulai : d;
      }
    });
  }

  Widget _date(String label, DateTime d, bool start) => Expanded(
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _pick(start),
          icon: const Icon(Icons.calendar_today, size: 16, color: kPrimary),
          label: Text(
            '$label\n${d.day}/${d.month}/${d.year}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      );

  Future<void> _submit(int hari) async {
    if (_alasan.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alasan pengajuan wajib diisi'),
          backgroundColor: kRed,
        ),
      );
      return;
    }

    if (_jenis == 'Cuti Tahunan' && hari > AppState.sisaCuti) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Sisa cuti tahunan Anda tidak mencukupi (Tersisa: ${AppState.sisaCuti} hari)'),
          backgroundColor: kRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final record = await AppState.submitCuti(
      jenis: _jenis,
      mulai: _mulai,
      selesai: _selesai,
      alasan: _alasan.text.trim(),
      hari: hari,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _alasan.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengajuan izin/cuti berhasil dikirim!'),
        backgroundColor: kGreen,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CutiDetailPage(record: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hari = _selesai.difference(_mulai).inDays + 1;

    return Column(children: [
      const AppHeader('Izin & Cuti', 'Kelola pengajuan permohonan ketidakhadiran'),
      Container(
        color: Colors.white,
        child: TabBar(
          controller: _tab,
          labelColor: kPrimary,
          indicatorColor: kPrimary,
          indicatorWeight: 3,
          unselectedLabelColor: kMuted,
          tabs: const [
            Tab(text: 'Ajukan Baru'),
            Tab(text: 'Riwayat Pengajuan'),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _tab,
          children: [
            // TAB 1: FORM AJUKAN BARU
            AnimatedBuilder(
              animation: AppState.user,
              builder: (_, __) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AppCard(
                    color: const Color(0xFFEEF2FF),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE0E7FF),
                        child: Icon(Icons.event_available, color: kPrimary),
                      ),
                      title: const Text('Sisa Cuti Tahunan 2026',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${AppState.sisaCuti} hari tersisa'),
                      trailing: const Text(
                        '12 hari / tahun',
                        style: TextStyle(color: kMuted, fontSize: 12),
                      ),
                    ),
                  ),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _jenis,
                          decoration: const InputDecoration(labelText: 'Jenis Pengajuan'),
                          items: const [
                            'Cuti Tahunan',
                            'Izin Kepentingan Pribadi',
                            'Sakit (Surat Dokter)',
                            'Cuti Melahirkan/Khusus',
                          ]
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => setState(() => _jenis = v!),
                        ),
                        const SizedBox(height: 14),
                        Row(children: [
                          _date('Mulai', _mulai, true),
                          const SizedBox(width: 10),
                          _date('Selesai', _selesai, false),
                        ]),
                        const SizedBox(height: 10),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: kBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Durasi Pengajuan:'),
                              Text(
                                '$hari hari kerja',
                                style: const TextStyle(
                                  color: kPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _alasan,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Alasan Lengkap Pengajuan',
                            hintText: 'Tuliskan alasan izin/cuti dengan jelas...',
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: kMuted),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Pengajuan akan langsung diteruskan ke atasan langsung.',
                                style: TextStyle(color: kMuted, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : () => _submit(hari),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _isSubmitting ? 'Mengirim...' : 'Kirim Pengajuan Cuti',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            // TAB 2: RIWAYAT PENGAJUAN
            AnimatedBuilder(
              animation: AppState.cutiHistory,
              builder: (_, __) {
                final list = AppState.cutiHistory.value;
                if (list.isEmpty) {
                  return const Center(
                    child: Text('Belum ada riwayat pengajuan cuti/izin',
                        style: TextStyle(color: kMuted)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, idx) {
                    final item = list[idx];
                    final isPending = item.status == 'Menunggu';
                    final isApproved = item.status == 'Disetujui';
                    final isCancelled = item.status == 'Dibatalkan';
                    final badgeColor = isApproved
                        ? kGreen
                        : (isPending
                            ? kYellow
                            : (isCancelled ? kMuted : kRed));

                    return AppCard(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CutiDetailPage(record: item),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.jenis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                StatusBadge(item.status, badgeColor),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Periode: ${item.mulai.day}/${item.mulai.month}/${item.mulai.year} – ${item.selesai.day}/${item.selesai.month}/${item.selesai.year} (${item.hari} hari)',
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Alasan: ${item.alasan}',
                              style: const TextStyle(color: kMuted, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.id,
                                  style: const TextStyle(
                                    color: kPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Row(
                                  children: [
                                    Text('Lihat Detail',
                                        style: TextStyle(
                                            color: kPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                    Icon(Icons.chevron_right, size: 16, color: kPrimary),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    ]);
  }
}
