import 'core_imports.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _i = 0;
  final _pages = const [HomePage(), RiwayatPage(), SizedBox(), CutiPage(), ProfilPage()];

  Widget _item(IconData icon, String label, int idx) => Expanded(
        child: InkWell(
          onTap: () => setState(() => _i = idx),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: _i == idx ? kPrimary : kMuted),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: _i == idx ? FontWeight.w700 : FontWeight.w400,
                    color: _i == idx ? kPrimary : kMuted)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: _i, children: _pages),
        bottomNavigationBar: Container(
          color: Colors.white,
          padding: EdgeInsets.only(
              top: 8, bottom: MediaQuery.of(context).padding.bottom + 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _item(Icons.home_outlined, 'Beranda', 0),
            _item(Icons.calendar_month_outlined, 'Riwayat', 1),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ScanPage())),
                child: const Column(mainAxisSize: MainAxisSize.min, children: [
                  CircleAvatar(
                      radius: 26,
                      backgroundColor: kPrimary,
                      child: Icon(Icons.qr_code_scanner, color: Colors.white)),
                  Text('Scan', style: TextStyle(fontSize: 11, color: kMuted)),
                ]),
              ),
            ),
            _item(Icons.edit_note, 'Izin/Cuti', 3),
            _item(Icons.person_outline, 'Profil', 4),
          ]),
        ),
      );
}
