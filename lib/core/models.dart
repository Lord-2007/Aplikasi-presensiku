class UserModel {
  final String nip;
  final String nama;
  final String jabatan;
  final String department;
  final String lokasi;
  final String email;
  final String phone;
  final int sisaCuti;
  final bool biometricEnabled;

  const UserModel({
    required this.nip,
    required this.nama,
    required this.jabatan,
    required this.department,
    required this.lokasi,
    required this.email,
    required this.phone,
    required this.sisaCuti,
    this.biometricEnabled = true,
  });

  UserModel copyWith({
    String? nip,
    String? nama,
    String? jabatan,
    String? department,
    String? lokasi,
    String? email,
    String? phone,
    int? sisaCuti,
    bool? biometricEnabled,
  }) {
    return UserModel(
      nip: nip ?? this.nip,
      nama: nama ?? this.nama,
      jabatan: jabatan ?? this.jabatan,
      department: department ?? this.department,
      lokasi: lokasi ?? this.lokasi,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      sisaCuti: sisaCuti ?? this.sisaCuti,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'nip': nip,
        'nama': nama,
        'jabatan': jabatan,
        'department': department,
        'lokasi': lokasi,
        'email': email,
        'phone': phone,
        'sisaCuti': sisaCuti,
        'biometricEnabled': biometricEnabled,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        nip: json['nip'] as String? ?? '19940812',
        nama: json['nama'] as String? ?? 'Bucai Santoso',
        jabatan: json['jabatan'] as String? ?? 'Staff Akademik & TI',
        department: json['department'] as String? ?? 'Teknologi Informasi',
        lokasi: json['lokasi'] as String? ?? 'UTY Kampus 1 Yogyakarta',
        email: json['email'] as String? ?? 'bucai.santoso@uty.ac.id',
        phone: json['phone'] as String? ?? '+62 812-3456-7890',
        sisaCuti: json['sisaCuti'] as int? ?? 8,
        biometricEnabled: json['biometricEnabled'] as bool? ?? true,
      );

  static const defaultUser = UserModel(
    nip: '19940812',
    nama: 'Bucai Santoso',
    jabatan: 'Staff Akademik & TI',
    department: 'Teknologi Informasi',
    lokasi: 'UTY Kampus 1 Yogyakarta',
    email: 'bucai.santoso@uty.ac.id',
    phone: '+62 812-3456-7890',
    sisaCuti: 8,
    biometricEnabled: true,
  );
}

class AttendanceRecord {
  final String id;
  final String date; // yyyy-MM-dd
  final DateTime? clockIn;
  final DateTime? clockOut;
  final String status; // 'Hadir', 'Terlambat', 'Izin', 'Cuti'
  final String lokasi;
  final String? keterangan;
  final String? fotoPath;
  final double? latitude;
  final double? longitude;

  const AttendanceRecord({
    required this.id,
    required this.date,
    this.clockIn,
    this.clockOut,
    required this.status,
    required this.lokasi,
    this.keterangan,
    this.fotoPath,
    this.latitude,
    this.longitude,
  });

  AttendanceRecord copyWith({
    String? id,
    String? date,
    DateTime? clockIn,
    DateTime? clockOut,
    String? status,
    String? lokasi,
    String? keterangan,
    String? fotoPath,
    double? latitude,
    double? longitude,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      status: status ?? this.status,
      lokasi: lokasi ?? this.lokasi,
      keterangan: keterangan ?? this.keterangan,
      fotoPath: fotoPath ?? this.fotoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'clockIn': clockIn?.toIso8601String(),
        'clockOut': clockOut?.toIso8601String(),
        'status': status,
        'lokasi': lokasi,
        'keterangan': keterangan,
        'fotoPath': fotoPath,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: json['id'] as String? ?? '',
        date: json['date'] as String? ?? '',
        clockIn: json['clockIn'] != null
            ? DateTime.tryParse(json['clockIn'] as String)
            : null,
        clockOut: json['clockOut'] != null
            ? DateTime.tryParse(json['clockOut'] as String)
            : null,
        status: json['status'] as String? ?? 'Hadir',
        lokasi: json['lokasi'] as String? ?? 'UTY Kampus 1 Yogyakarta',
        keterangan: json['keterangan'] as String?,
        fotoPath: json['fotoPath'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}

class CutiRecord {
  final String id;
  final String jenis;
  final DateTime mulai;
  final DateTime selesai;
  final int hari;
  final String alasan;
  final String status; // 'Menunggu', 'Disetujui', 'Dibatalkan', 'Ditolak'
  final DateTime createdAt;
  final String penyetuju;

  const CutiRecord({
    required this.id,
    required this.jenis,
    required this.mulai,
    required this.selesai,
    required this.hari,
    required this.alasan,
    required this.status,
    required this.createdAt,
    this.penyetuju = 'Dwi Maharani · Kepala Bagian TI',
  });

  CutiRecord copyWith({
    String? id,
    String? jenis,
    DateTime? mulai,
    DateTime? selesai,
    int? hari,
    String? alasan,
    String? status,
    DateTime? createdAt,
    String? penyetuju,
  }) {
    return CutiRecord(
      id: id ?? this.id,
      jenis: jenis ?? this.jenis,
      mulai: mulai ?? this.mulai,
      selesai: selesai ?? this.selesai,
      hari: hari ?? this.hari,
      alasan: alasan ?? this.alasan,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      penyetuju: penyetuju ?? this.penyetuju,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jenis': jenis,
        'mulai': mulai.toIso8601String(),
        'selesai': selesai.toIso8601String(),
        'hari': hari,
        'alasan': alasan,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'penyetuju': penyetuju,
      };

  factory CutiRecord.fromJson(Map<String, dynamic> json) => CutiRecord(
        id: json['id'] as String? ?? '',
        jenis: json['jenis'] as String? ?? 'Cuti Tahunan',
        mulai: DateTime.tryParse(json['mulai'] as String? ?? '') ??
            DateTime.now(),
        selesai: DateTime.tryParse(json['selesai'] as String? ?? '') ??
            DateTime.now(),
        hari: json['hari'] as int? ?? 1,
        alasan: json['alasan'] as String? ?? '',
        status: json['status'] as String? ?? 'Menunggu',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        penyetuju: json['penyetuju'] as String? ??
            'Dwi Maharani · Kepala Bagian TI',
      );
}
