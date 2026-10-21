import '../core_imports.dart';
import '../auth/login_page.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  Widget _menu(IconData i, String t, String s) => ListTile(
        leading: CircleAvatar(
            backgroundColor: const Color(0xFFE0E7FF), child: Icon(i, color: kPrimary)),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(s, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right),
      );

  @override
  Widget build(BuildContext context) => Column(children: [
        const AppHeader('Profil & Pengaturan', 'Kelola akun karyawan'),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            const AppCard(
              child: Column(children: [
                ListTile(
                  leading: CircleAvatar(radius: 28, child: Icon(Icons.person)),
                  title: Text(AppState.nama,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  subtitle: Text('${AppState.jabatan} • NIP: ${AppState.nip}'),
                ),
                Row(children: [
                  StatusBadge('Karyawan Tetap', kGreen),
                  SizedBox(width: 8),
                  StatusBadge('Software Engineering', kPrimary),
                ]),
                SizedBox(height: 8),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Bergabung: 12 Agu 2021',
                        style: TextStyle(color: kMuted, fontSize: 12))),
              ]),
            ),
            AppCard(
              child: Column(children: [
                _menu(Icons.person_outline, 'Informasi Pribadi', 'Kontak, alamat, data diri'),
                _menu(Icons.shield_outlined, 'Keamanan Akun', 'PIN dan autentikasi biometrik'),
                _menu(Icons.notifications_none, 'Notifikasi', 'Pengingat presensi aktif'),
                _menu(Icons.place_outlined, 'Lokasi Presensi', AppState.lokasi),
              ]),
            ),
            AppCard(
              child: Column(children: [
                _menu(Icons.help_outline, 'Pusat Bantuan & Kebijakan', 'FAQ dan kebijakan HRD'),
                ListTile(
                  leading: const Icon(Icons.logout, color: kRed),
                  title: const Text('Keluar dari Akun', style: TextStyle(color: kRed)),
                  onTap: () {
                    AppState.clockIn.value = null;
                    AppState.clockOut.value = null;
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (_) => false);
                  },
                ),
              ]),
            ),
            const Center(
                child: Text('PresensiKu v2.6.0 · PT Menara Tekno Nusantara',
                    style: TextStyle(color: kMuted, fontSize: 11))),
          ]),
        ),
      ]);
}
