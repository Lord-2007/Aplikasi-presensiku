import '../core_imports.dart';
import '../auth/login_page.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  Widget _menu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0E7FF),
          child: Icon(icon, color: kPrimary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: kMuted)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: kMuted),
      );

  void _showInfoPribadi(BuildContext context) {
    final user = AppState.user.value;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Informasi Pribadi Karyawan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              dense: true,
              leading: const Icon(Icons.badge, color: kPrimary),
              title: const Text('Nomor Induk Pegawai (NIP)'),
              subtitle: Text(user.nip, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.person, color: kPrimary),
              title: const Text('Nama Lengkap'),
              subtitle: Text(user.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.work, color: kPrimary),
              title: const Text('Jabatan & Divisi'),
              subtitle: Text('${user.jabatan} (${user.department})',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.email, color: kPrimary),
              title: const Text('Alamat Email Perusahaan'),
              subtitle: Text(user.email, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.phone, color: kPrimary),
              title: const Text('Nomor Telepon / WhatsApp'),
              subtitle: Text(user.phone, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showKeamanan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).padding.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Keamanan & Biometrik',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: AppState.user.value.biometricEnabled,
                title: const Text('Autentikasi Sidik Jari / Face ID'),
                subtitle: const Text('Gunakan biometrik untuk login cepat'),
                onChanged: (val) {
                  setModalState(() {
                    AppState.updateUser(
                      AppState.user.value.copyWith(biometricEnabled: val),
                    );
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset, color: kPrimary),
                title: const Text('Ganti Kata Sandi'),
                subtitle: const Text('Perbarui kata sandi akun karyawan Anda'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tautan ubah kata sandi telah dikirim ke email HRD.'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLokasi(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Zona Lokasi Presensi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AppCard(
              color: const Color(0xFFEEF2FF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppState.lokasi,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Jl. Jend. Sudirman Kav. 21, Jakarta Selatan'),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      StatusBadge('Radius GPS: 50 Meter', kGreen),
                      SizedBox(width: 8),
                      StatusBadge('Geofence Aktif', kPrimary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBantuan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).padding.bottom + 20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pusat Bantuan & Kebijakan HRD',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListTile(
              dense: true,
              leading: Icon(Icons.alarm, color: kPrimary),
              title: Text('Ketentuan Jam Kerja'),
              subtitle: Text('Shift pagi dimulai 08:00 WIB. Keterlambatan di atas 5 menit akan tercatat sebagai Terlambat.'),
            ),
            ListTile(
              dense: true,
              leading: Icon(Icons.sick, color: kPrimary),
              title: Text('Ketentuan Izin Sakit'),
              subtitle: Text('Izin sakit lebih dari 1 hari wajib menyertakan surat keterangan dokter resmi.'),
            ),
            ListTile(
              dense: true,
              leading: Icon(Icons.contact_support, color: kGreen),
              title: Text('Kontak Support HRD'),
              subtitle: Text('helpdesk@menaratekno.com · (021) 555-0199'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Sesi login Anda akan dihapus dari perangkat ini. Anda perlu masuk kembali dengan NIP dan kata sandi saat membuka aplikasi lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AppState.logout();

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        const AppHeader('Profil & Pengaturan', 'Kelola akun karyawan'),
        Expanded(
          child: AnimatedBuilder(
            animation: AppState.user,
            builder: (_, __) => ListView(padding: const EdgeInsets.all(16), children: [
              AppCard(
                child: Column(children: [
                  ListTile(
                    leading: const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFE0E7FF),
                      child: Icon(Icons.person, size: 32, color: kPrimary),
                    ),
                    title: Text(
                      AppState.nama,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    subtitle: Text('${AppState.jabatan} • NIP: ${AppState.nip}'),
                  ),
                  const Row(children: [
                    StatusBadge('Karyawan Tetap', kGreen),
                    SizedBox(width: 8),
                    StatusBadge('Software Engineering', kPrimary),
                  ]),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Bergabung: 12 Agu 2021',
                        style: TextStyle(color: kMuted, fontSize: 12)),
                  ),
                ]),
              ),
              AppCard(
                child: Column(children: [
                  _menu(
                    icon: Icons.person_outline,
                    title: 'Informasi Pribadi',
                    subtitle: 'Kontak, alamat, data diri pegawai',
                    onTap: () => _showInfoPribadi(context),
                  ),
                  _menu(
                    icon: Icons.shield_outlined,
                    title: 'Keamanan Akun',
                    subtitle: 'PIN dan autentikasi biometrik',
                    onTap: () => _showKeamanan(context),
                  ),
                  _menu(
                    icon: Icons.notifications_none,
                    title: 'Notifikasi',
                    subtitle: 'Pengingat presensi aktif pukul 07:45 & 17:00 WIB',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifikasi presensi aktif.')),
                      );
                    },
                  ),
                  _menu(
                    icon: Icons.place_outlined,
                    title: 'Lokasi Presensi',
                    subtitle: AppState.lokasi,
                    onTap: () => _showLokasi(context),
                  ),
                ]),
              ),
              AppCard(
                child: Column(children: [
                  _menu(
                    icon: Icons.help_outline,
                    title: 'Pusat Bantuan & Kebijakan',
                    subtitle: 'FAQ dan kebijakan HRD',
                    onTap: () => _showBantuan(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: kRed),
                    title: const Text(
                      'Keluar dari Akun',
                      style: TextStyle(color: kRed, fontWeight: FontWeight.w600),
                    ),
                    onTap: () => _logout(context),
                  ),
                ]),
              ),
              const Center(
                child: Text('PresensiKu v1.0.0 · PT Menara Tekno Nusantara',
                    style: TextStyle(color: kMuted, fontSize: 11)),
              ),
            ]),
          ),
        ),
      ]);
}
