import '../core_imports.dart';

class CutiDetailPage extends StatefulWidget {
  final CutiRecord record;

  const CutiDetailPage({super.key, required this.record});

  @override
  State<CutiDetailPage> createState() => _CutiDetailPageState();
}

class _CutiDetailPageState extends State<CutiDetailPage> {
  late CutiRecord _currentRecord;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _currentRecord = widget.record;
  }

  Widget _step(String t, String s, Color c, bool done) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(done ? Icons.check_circle : Icons.radio_button_checked, color: c),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(s, style: const TextStyle(fontSize: 12)),
      );

  Future<void> _cancelRequest() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pengajuan?'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pengajuan ini? Sisa kuota cuti akan otomatis dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);
    await AppState.cancelCuti(_currentRecord.id);

    if (!mounted) return;
    setState(() {
      _isCancelling = false;
      _currentRecord = _currentRecord.copyWith(status: 'Dibatalkan');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengajuan berhasil dibatalkan dan kuota cuti dikembalikan.'),
        backgroundColor: kGreen,
      ),
    );
  }

  void _contactSupervisor() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hubungi Penyetuju Pengajuan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _currentRecord.penyetuju,
              style: const TextStyle(color: kMuted),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFDCFCE7),
                child: Icon(Icons.chat, color: kGreen),
              ),
              title: const Text('WhatsApp Manager'),
              subtitle: const Text('Kirim pesan singkat permohonan persetujuan'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menghubungkan ke WhatsApp atasan...'),
                    backgroundColor: kGreen,
                  ),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE0E7FF),
                child: Icon(Icons.email_outlined, color: kPrimary),
              ),
              title: const Text('Email Resmi HRD & Atasan'),
              subtitle: const Text('hrd@menaratekno.com'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membuka aplikasi email...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _currentRecord;
    final isPending = r.status == 'Menunggu';
    final isApproved = r.status == 'Disetujui';
    final isCancelled = r.status == 'Dibatalkan';

    final badgeColor = isApproved
        ? kGreen
        : (isPending ? kYellow : (isCancelled ? kMuted : kRed));

    return Scaffold(
      body: Column(children: [
        AppHeader('Detail Pengajuan', r.id, back: true),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            AppCard(
              color: isApproved
                  ? const Color(0xFFF0FDF4)
                  : (isPending
                      ? const Color(0xFFFFF7E6)
                      : (isCancelled
                          ? const Color(0xFFF3F4F6)
                          : const Color(0xFFFEF2F2))),
              child: Column(children: [
                Icon(
                  isApproved
                      ? Icons.check_circle
                      : (isPending
                          ? Icons.schedule
                          : (isCancelled ? Icons.cancel : Icons.error)),
                  color: badgeColor,
                  size: 38,
                ),
                const SizedBox(height: 6),
                Text(
                  r.status.toUpperCase(),
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isApproved
                      ? 'Pengajuan telah disetujui atasan. Selamat beristirahat!'
                      : (isPending
                          ? 'Pengajuan sedang ditinjau atasan. Estimasi respons maksimal 1 hari kerja.'
                          : (isCancelled
                              ? 'Pengajuan ini telah dibatalkan.'
                              : 'Pengajuan tidak dapat disetujui oleh atasan.')),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ]),
            ),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(r.jenis,
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  StatusBadge('${r.hari} hari', kPrimary),
                ]),
                const Divider(height: 20),
                Text(
                  'Periode: ${r.mulai.day}/${r.mulai.month}/${r.mulai.year} – ${r.selesai.day}/${r.selesai.month}/${r.selesai.year}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text('Alasan: ${r.alasan}'),
                const SizedBox(height: 6),
                Text('Penyetuju: ${r.penyetuju}',
                    style: const TextStyle(color: kMuted, fontSize: 12)),
              ]),
            ),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Progres Pengajuan',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _step('Pengajuan dikirim',
                    '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',
                    kGreen, true),
                _step(
                    'Review atasan',
                    isApproved
                        ? 'Disetujui atasan'
                        : (isCancelled ? 'Dibatalkan' : 'Sedang diproses'),
                    isApproved ? kGreen : (isCancelled ? kMuted : kPrimary),
                    isApproved || isCancelled),
                _step(
                    'Keputusan akhir',
                    r.status,
                    badgeColor,
                    isApproved || isCancelled),
              ]),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _contactSupervisor,
              icon: const Icon(Icons.chat_bubble_outline, color: kPrimary),
              label: const Text('Hubungi Atasan Langsung'),
            ),
            if (isPending) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: kRed,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isCancelling ? null : _cancelRequest,
                icon: const Icon(Icons.cancel_outlined),
                label: Text(_isCancelling
                    ? 'Membatalkan...'
                    : 'Batalkan Pengajuan Ini'),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}
