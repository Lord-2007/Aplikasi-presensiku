import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class LocalDb {
  static const _keyIsLoggedIn = 'app_is_logged_in';
  static const _keyUserData = 'app_user_data';
  static const _keyTodayAttendance = 'app_today_attendance';
  static const _keyAttendanceHistory = 'app_attendance_history';
  static const _keyCutiHistory = 'app_cuti_history';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('LocalDb belum diinisialisasi. Panggil LocalDb.init() terlebih dahulu.');
    }
    return _prefs!;
  }

  // --- Sesi Login ---
  static bool get isLoggedIn {
    try {
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setLoggedIn(bool value) async {
    try {
      await prefs.setBool(_keyIsLoggedIn, value);
    } catch (_) {}
  }

  // --- Data User ---
  static UserModel getUser() {
    try {
      final raw = prefs.getString(_keyUserData);
      if (raw == null || raw.isEmpty) {
        return UserModel.defaultUser;
      }
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return UserModel.defaultUser;
    }
  }

  static Future<void> saveUser(UserModel user) async {
    try {
      await prefs.setString(_keyUserData, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  // --- Presensi Hari Ini ---
  static AttendanceRecord? getTodayAttendance(String todayDateStr) {
    try {
      final raw = prefs.getString(_keyTodayAttendance);
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final record = AttendanceRecord.fromJson(map);
      // Validasi apakah record ini benar untuk tanggal hari ini
      if (record.date == todayDateStr) {
        return record;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveTodayAttendance(AttendanceRecord record) async {
    try {
      await prefs.setString(_keyTodayAttendance, jsonEncode(record.toJson()));
    } catch (_) {}
  }

  // --- Riwayat Presensi ---
  static List<AttendanceRecord> getAttendanceHistory() {
    try {
      final raw = prefs.getString(_keyAttendanceHistory);
      if (raw == null || raw.isEmpty) {
        return _defaultAttendanceHistory();
      }
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _defaultAttendanceHistory();
    }
  }

  static Future<void> saveAttendanceHistory(List<AttendanceRecord> list) async {
    try {
      final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
      await prefs.setString(_keyAttendanceHistory, encoded);
    } catch (_) {}
  }

  // --- Riwayat Cuti ---
  static List<CutiRecord> getCutiHistory() {
    try {
      final raw = prefs.getString(_keyCutiHistory);
      if (raw == null || raw.isEmpty) {
        return _defaultCutiHistory();
      }
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CutiRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _defaultCutiHistory();
    }
  }

  static Future<void> saveCutiHistory(List<CutiRecord> list) async {
    try {
      final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
      await prefs.setString(_keyCutiHistory, encoded);
    } catch (_) {}
  }

  // --- Logout (Hanya hapus sesi login dan hari ini, riwayat tetap aman) ---
  static Future<void> clearSession() async {
    await prefs.remove(_keyIsLoggedIn);
  }

  // --- Reset Penuh (Debugging / Factory reset) ---
  static Future<void> clearAll() async {
    await prefs.clear();
  }

  // --- Data Awal Bawaan ---
  static List<AttendanceRecord> _defaultAttendanceHistory() {
    final now = DateTime.now();
    return [
      AttendanceRecord(
        id: 'att-4',
        date: '${now.year}-${_pad(now.month)}-04',
        clockIn: DateTime(now.year, now.month, 4, 8, 12),
        clockOut: DateTime(now.year, now.month, 4, 17, 5),
        status: 'Terlambat',
        lokasi: 'UTY Kampus 1 Yogyakarta',
        keterangan: 'Terlambat 12 menit',
      ),
      AttendanceRecord(
        id: 'att-3',
        date: '${now.year}-${_pad(now.month)}-03',
        clockIn: DateTime(now.year, now.month, 3, 7, 58),
        clockOut: DateTime(now.year, now.month, 3, 17, 2),
        status: 'Hadir',
        lokasi: 'UTY Kampus 1 Yogyakarta',
        keterangan: 'Tepat waktu',
      ),
      AttendanceRecord(
        id: 'att-2',
        date: '${now.year}-${_pad(now.month)}-02',
        clockIn: null,
        clockOut: null,
        status: 'Cuti',
        lokasi: '-',
        keterangan: 'Cuti Tahunan',
      ),
    ];
  }

  static List<CutiRecord> _defaultCutiHistory() {
    final now = DateTime.now();
    return [
      CutiRecord(
        id: 'REQ-CT-2026-1048',
        jenis: 'Cuti Tahunan',
        mulai: now.subtract(const Duration(days: 10)),
        selesai: now.subtract(const Duration(days: 9)),
        hari: 2,
        alasan: 'Keperluan keluarga di luar kota',
        status: 'Disetujui',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ];
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
