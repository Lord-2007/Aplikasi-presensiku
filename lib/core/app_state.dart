import 'package:flutter/foundation.dart';

/// State sederhana (in-memory) untuk demo. Ganti dengan API Node.js + PostgreSQL.
class AppState {
  static final clockIn = ValueNotifier<DateTime?>(null);
  static final clockOut = ValueNotifier<DateTime?>(null);

  static const nama = 'Bucai Santoso';
  static const jabatan = 'Software Engineer';
  static const nip = '19940812';
  static const lokasi = 'HQ Menara Tekno';
}
