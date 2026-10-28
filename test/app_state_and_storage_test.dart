import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presensiku/core/local_db.dart';
import 'package:presensiku/core/app_state.dart';
import 'package:presensiku/core/location_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalDb.init();
    await AppState.init();
  });

  group('Session & LocalDb Tests', () {
    test('Awalnya user belum login', () {
      expect(AppState.isLoggedIn, false);
      expect(LocalDb.isLoggedIn, false);
    });

    test('Login berhasil dan menyimpan sesi ke penyimpanan lokal', () async {
      final success = await AppState.login(nipInput: '19940812', passwordInput: '123456');
      expect(success, true);
      expect(AppState.isLoggedIn, true);
      expect(LocalDb.isLoggedIn, true);

      // Simulasikan app ditutup dan dibuka ulang (panggil AppState.init lagi)
      await AppState.init();
      expect(AppState.isLoggedIn, true);
      expect(AppState.nama, 'Bucai Santoso');
      expect(AppState.nip, '19940812');
    });

    test('Logout menghapus sesi login dari penyimpanan lokal', () async {
      await AppState.login(nipInput: '19940812', passwordInput: '123456');
      expect(AppState.isLoggedIn, true);

      await AppState.logout();
      expect(AppState.isLoggedIn, false);
      expect(LocalDb.isLoggedIn, false);

      // Simulasikan restart app
      await AppState.init();
      expect(AppState.isLoggedIn, false);
    });
  });

  group('Presensi & Attendance Persistence Tests', () {
    test('Clock In dan Clock Out tersimpan permanen', () async {
      final clockInTime = DateTime(2026, 10, 21, 7, 55);
      final clockOutTime = DateTime(2026, 10, 21, 17, 2);

      await AppState.doClockIn(
        time: clockInTime,
        fotoPath: '/dummy/selfie.jpg',
        latitude: -6.225586,
        longitude: 106.824681,
        customLokasi: 'HQ Menara Tekno (Radius Valid)',
      );
      expect(AppState.clockIn.value, clockInTime);

      await AppState.doClockOut(time: clockOutTime);
      expect(AppState.clockOut.value, clockOutTime);

      // Cek apakah ada di riwayat
      final history = AppState.attendanceHistory.value;
      expect(history.isNotEmpty, true);
      expect(history.first.status, 'Hadir');
      expect(history.first.fotoPath, '/dummy/selfie.jpg');
      expect(history.first.latitude, -6.225586);
      expect(history.first.longitude, 106.824681);

      // Simulasikan aplikasi di-restart
      await AppState.init();
      expect(AppState.clockIn.value, clockInTime);
      expect(AppState.clockOut.value, clockOutTime);
      expect(AppState.attendanceHistory.value.first.fotoPath, '/dummy/selfie.jpg');
    });
  });

  group('LocationService Tests', () {
    test('Format distance correctly under and above 1km', () {
      expect(LocationService.formatDistance(45.2), '45 m');
      expect(LocationService.formatDistance(1500), '1.50 km');
      expect(LocationService.formatDistance(0), '0 m');
    });
  });

  group('Izin & Cuti Persistence Tests', () {
    test('Pengajuan cuti memotong kuota dan tersimpan permanen', () async {
      final initialQuota = AppState.sisaCuti;

      final cuti = await AppState.submitCuti(
        jenis: 'Cuti Tahunan',
        mulai: DateTime.now().add(const Duration(days: 2)),
        selesai: DateTime.now().add(const Duration(days: 3)),
        alasan: 'Acara keluarga',
        hari: 2,
      );

      expect(AppState.sisaCuti, initialQuota - 2);
      expect(AppState.cutiHistory.value.any((c) => c.id == cuti.id), true);

      // Simulasikan restart app
      await AppState.init();
      expect(AppState.sisaCuti, initialQuota - 2);
      expect(AppState.cutiHistory.value.any((c) => c.id == cuti.id), true);

      // Batalkan pengajuan cuti
      await AppState.cancelCuti(cuti.id);
      expect(AppState.sisaCuti, initialQuota); // Kuota dikembalikan
    });
  });
}
