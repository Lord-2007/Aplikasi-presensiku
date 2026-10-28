import 'package:flutter/foundation.dart';
import 'models.dart';
import 'local_db.dart';

class AppState {
  static final clockIn = ValueNotifier<DateTime?>(null);
  static final clockOut = ValueNotifier<DateTime?>(null);

  static final user = ValueNotifier<UserModel>(UserModel.defaultUser);
  static final attendanceHistory = ValueNotifier<List<AttendanceRecord>>([]);
  static final cutiHistory = ValueNotifier<List<CutiRecord>>([]);
  static final isLoggedInNotifier = ValueNotifier<bool>(false);

  static bool get isLoggedIn => isLoggedInNotifier.value;

  // Convenience getters for backward compatibility
  static String get nama => user.value.nama;
  static String get jabatan => user.value.jabatan;
  static String get nip => user.value.nip;
  static String get lokasi => user.value.lokasi;
  static String get department => user.value.department;
  static String get email => user.value.email;
  static String get phone => user.value.phone;
  static int get sisaCuti => user.value.sisaCuti;

  static String _todayKey() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  /// Inisialisasi awal dari LocalDb
  static Future<void> init() async {
    await LocalDb.init();

    isLoggedInNotifier.value = LocalDb.isLoggedIn;
    user.value = LocalDb.getUser();
    attendanceHistory.value = LocalDb.getAttendanceHistory();
    cutiHistory.value = LocalDb.getCutiHistory();

    // Cek presensi hari ini
    final today = _todayKey();
    final todayRecord = LocalDb.getTodayAttendance(today);
    if (todayRecord != null) {
      clockIn.value = todayRecord.clockIn;
      clockOut.value = todayRecord.clockOut;
    } else {
      clockIn.value = null;
      clockOut.value = null;
    }
  }

  /// Proses Login
  static Future<bool> login({
    required String nipInput,
    required String passwordInput,
  }) async {
    // Validasi kredensial (Demo atau format NIP minimal)
    if (nipInput.trim().isEmpty || passwordInput.trim().isEmpty) {
      return false;
    }

    // Jika user memasukkan NIP demo atau NIP karyawan valid
    UserModel loggedUser;
    if (nipInput == UserModel.defaultUser.nip) {
      loggedUser = UserModel.defaultUser;
    } else {
      loggedUser = UserModel(
        nip: nipInput,
        nama: 'Karyawan ($nipInput)',
        jabatan: 'Staff Operasional',
        department: 'Operasional',
        lokasi: 'UTY Kampus 1 Yogyakarta',
        email: 'karyawan.$nipInput@uty.ac.id',
        phone: '+62 812-9876-5432',
        sisaCuti: 12,
      );
    }

    await LocalDb.setLoggedIn(true);
    await LocalDb.saveUser(loggedUser);

    user.value = loggedUser;
    isLoggedInNotifier.value = true;
    return true;
  }

  /// Proses Logout
  static Future<void> logout() async {
    await LocalDb.clearSession();
    isLoggedInNotifier.value = false;
    clockIn.value = null;
    clockOut.value = null;
  }

  /// Lakukan Clock In
  static Future<void> doClockIn({
    DateTime? time,
    String? customLokasi,
    String? fotoPath,
    double? latitude,
    double? longitude,
    String? customKeterangan,
  }) async {
    final now = time ?? DateTime.now();
    clockIn.value = now;

    final today = _todayKey();
    final loc = customLokasi ?? user.value.lokasi;

    // Evaluasi status keterlambatan (Jam kerja 08:00 WIB)
    String status = 'Hadir';
    String? ket = customKeterangan ?? 'Tepat waktu';
    if (now.hour > 8 || (now.hour == 8 && now.minute > 5)) {
      final lateMinutes = (now.hour - 8) * 60 + now.minute;
      status = 'Terlambat';
      ket = customKeterangan ?? 'Terlambat $lateMinutes menit';
    }

    final newRecord = AttendanceRecord(
      id: 'att-$today',
      date: today,
      clockIn: now,
      clockOut: clockOut.value,
      status: status,
      lokasi: loc,
      keterangan: ket,
      fotoPath: fotoPath,
      latitude: latitude,
      longitude: longitude,
    );

    await LocalDb.saveTodayAttendance(newRecord);

    // Update list history
    final history = List<AttendanceRecord>.from(attendanceHistory.value);
    final idx = history.indexWhere((r) => r.date == today);
    if (idx >= 0) {
      history[idx] = newRecord;
    } else {
      history.insert(0, newRecord);
    }
    attendanceHistory.value = history;
    await LocalDb.saveAttendanceHistory(history);
  }

  /// Lakukan Clock Out
  static Future<void> doClockOut({
    DateTime? time,
    String? customLokasi,
    double? latitude,
    double? longitude,
  }) async {
    final now = time ?? DateTime.now();
    clockOut.value = now;

    final today = _todayKey();
    final existing = LocalDb.getTodayAttendance(today);

    final updatedRecord = AttendanceRecord(
      id: existing?.id ?? 'att-$today',
      date: today,
      clockIn: existing?.clockIn ?? clockIn.value ?? now,
      clockOut: now,
      status: existing?.status ?? 'Hadir',
      lokasi: customLokasi ?? existing?.lokasi ?? user.value.lokasi,
      keterangan: existing?.keterangan ?? 'Selesai bertugas',
      fotoPath: existing?.fotoPath,
      latitude: latitude ?? existing?.latitude,
      longitude: longitude ?? existing?.longitude,
    );

    await LocalDb.saveTodayAttendance(updatedRecord);

    // Update list history
    final history = List<AttendanceRecord>.from(attendanceHistory.value);
    final idx = history.indexWhere((r) => r.date == today);
    if (idx >= 0) {
      history[idx] = updatedRecord;
    } else {
      history.insert(0, updatedRecord);
    }
    attendanceHistory.value = history;
    await LocalDb.saveAttendanceHistory(history);
  }

  /// Ajukan Izin / Cuti
  static Future<CutiRecord> submitCuti({
    required String jenis,
    required DateTime mulai,
    required DateTime selesai,
    required String alasan,
    required int hari,
  }) async {
    final now = DateTime.now();
    final id = 'REQ-CT-${now.year}-${1000 + cutiHistory.value.length + 1}';

    final record = CutiRecord(
      id: id,
      jenis: jenis,
      mulai: mulai,
      selesai: selesai,
      hari: hari,
      alasan: alasan,
      status: 'Menunggu',
      createdAt: now,
    );

    // Kurangi kuota cuti tahunan jika jenisnya cuti tahunan
    if (jenis == 'Cuti Tahunan') {
      final newSisa = (user.value.sisaCuti - hari).clamp(0, 99);
      final updatedUser = user.value.copyWith(sisaCuti: newSisa);
      user.value = updatedUser;
      await LocalDb.saveUser(updatedUser);
    }

    // Simpan ke history cuti
    final list = List<CutiRecord>.from(cutiHistory.value);
    list.insert(0, record);
    cutiHistory.value = list;
    await LocalDb.saveCutiHistory(list);

    return record;
  }

  /// Batalkan Pengajuan Cuti
  static Future<void> cancelCuti(String id) async {
    final list = List<CutiRecord>.from(cutiHistory.value);
    final idx = list.indexWhere((c) => c.id == id);
    if (idx >= 0) {
      final old = list[idx];
      if (old.status != 'Dibatalkan') {
        list[idx] = old.copyWith(status: 'Dibatalkan');
        cutiHistory.value = list;
        await LocalDb.saveCutiHistory(list);

        // Kembalikan jatah cuti jika cuti tahunan
        if (old.jenis == 'Cuti Tahunan') {
          final restored = user.value.sisaCuti + old.hari;
          final updatedUser = user.value.copyWith(sisaCuti: restored);
          user.value = updatedUser;
          await LocalDb.saveUser(updatedUser);
        }
      }
    }
  }

  /// Update data profil pengguna
  static Future<void> updateUser(UserModel updated) async {
    user.value = updated;
    await LocalDb.saveUser(updated);
  }
}
