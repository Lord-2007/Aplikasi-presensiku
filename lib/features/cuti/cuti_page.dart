import '../core_imports.dart';

class CutiPage extends StatefulWidget {
  const CutiPage({super.key});
  @override
  State<CutiPage> createState() => _CutiPageState();
}

class _CutiPageState extends State<CutiPage> {
  String _jenis = 'Cuti Tahunan';
  DateTime _mulai = DateTime.now().add(const Duration(days: 3));
  DateTime _selesai = DateTime.now().add(const Duration(days: 4));
  final _alasan = TextEditingController();

  Future<void> _pick(bool start) async {
    final d = await showDatePicker(
        context: context,
        initialDate: start ? _mulai : _selesai,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
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
          onPressed: () => _pick(start),
          icon: const Icon(Icons.calendar_today, size: 16),
          label: Text('$label\n${d.day}/${d.month}/${d.year}', textAlign: TextAlign.center),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hari = _selesai.difference(_mulai).inDays + 1;
    return Column(children: [
      const AppHeader('Ajukan Izin / Cuti', 'Isi data pengajuan dengan lengkap'),
      Expanded(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const AppCard(
              color: Color(0xFFE0E7FF),
              child: ListTile(
                  leading: Icon(Icons.event_available, color: kPrimary),
                  title: Text('Sisa cuti tahunan 2026'),
                  subtitle: Text('8 hari'),
                  trailing: Text('12 hari/tahun'))),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              DropdownButtonFormField<String>(
                initialValue: _jenis,
                decoration: const InputDecoration(labelText: 'Jenis Pengajuan'),
                items: const ['Cuti Tahunan', 'Izin', 'Sakit']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _jenis = v!),
              ),
              const SizedBox(height: 12),
              Row(children: [
                _date('Mulai', _mulai, true),
                const SizedBox(width: 10),
                _date('Selesai', _selesai, false),
              ]),
              const SizedBox(height: 8),
              Text('Total durasi: $hari hari',
                  style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                  controller: _alasan,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Alasan Pengajuan')),
              const SizedBox(height: 8),
              const Text('Pengajuan akan diteruskan ke Dwi Maharani · Engineering Manager.',
                  style: TextStyle(color: kMuted, fontSize: 12)),
            ]),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: kPrimary, minimumSize: const Size.fromHeight(50)),
            onPressed: () {
              if (_alasan.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alasan wajib diisi')));
                return;
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CutiDetailPage(
                          jenis: _jenis,
                          mulai: _mulai,
                          selesai: _selesai,
                          alasan: _alasan.text,
                          hari: hari)));
            },
            icon: const Icon(Icons.send),
            label: const Text('Kirim Pengajuan'),
          ),
        ]),
      ),
    ]);
  }
}
