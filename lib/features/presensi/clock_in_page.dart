import '../core_imports.dart';

class ClockInPage extends StatefulWidget {
  const ClockInPage({super.key});
  @override
  State<ClockInPage> createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  final _now = DateTime.now();
  bool _selfie = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          const AppHeader('Konfirmasi Clock In', 'Pastikan data presensi sudah benar',
              back: true),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              AppCard(
                child: Column(children: [
                  Text(hms(_now),
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w800, color: kPrimary)),
                  Text(tgl(_now), style: const TextStyle(color: kMuted)),
                  const Divider(height: 24),
                  const ListTile(
                      leading: Icon(Icons.work_outline),
                      title: Text('Shift Reguler · 08:00–17:00 WIB')),
                ]),
              ),
              AppCard(
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Verifikasi Selfie',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    if (_selfie) const StatusBadge('Wajah cocok 98%', kGreen),
                  ]),
                  const SizedBox(height: 14),
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: const Color(0xFFE0E7FF),
                    child: Icon(_selfie ? Icons.verified_user : Icons.face,
                        size: 54, color: _selfie ? kGreen : kPrimary),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _selfie = true),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(_selfie ? 'Ulangi Selfie' : 'Ambil Selfie'),
                  ),
                  const Text('Pastikan wajah terlihat jelas dan pencahayaan cukup.',
                      style: TextStyle(color: kMuted, fontSize: 11)),
                ]),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: kGreen, minimumSize: const Size.fromHeight(50)),
                onPressed: !_selfie
                    ? null
                    : () {
                        AppState.clockIn.value = _now;
                        Navigator.pop(context);
                      },
                icon: const Icon(Icons.fingerprint),
                label: const Text('Konfirmasi Clock In'),
              ),
            ]),
          ),
        ]),
      );
}
