import 'package:geolocator/geolocator.dart';

class OfficeLocationCheck {
  final bool isSuccess;
  final String? errorMessage;
  final Position? position;
  final double distanceInMeters;
  final bool isWithinRadius;
  final String distanceFormatted;

  const OfficeLocationCheck({
    required this.isSuccess,
    this.errorMessage,
    this.position,
    this.distanceInMeters = 0,
    this.isWithinRadius = false,
    this.distanceFormatted = '-',
  });
}

class LocationService {
  // Koordinat Kampus 1 UTY (Universitas Teknologi Yogyakarta)
  static const String officeName = 'UTY Kampus 1 Yogyakarta';
  static const String officeAddress =
      'Jl. Siliwangi (Ring Road Utara), Jombor, Sleman, D.I. Yogyakarta 55285';
  static const double officeLatitude = -7.747344;
  static const double officeLongitude = 110.355519;
  static const double maxRadiusMeters = 100.0; // Radius toleransi 100 meter

  /// Format jarak agar mudah dibaca pengguna (meter / km)
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }

  /// Memeriksa status GPS, izin, dan menghitung jarak terhadap titik lokasi kantor / kampus
  static Future<OfficeLocationCheck> checkLocationProximity() async {
    try {
      // 1. Cek apakah GPS aktif
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const OfficeLocationCheck(
          isSuccess: false,
          errorMessage: 'GPS / Layanan lokasi belum aktif. Aktifkan GPS pada perangkat Anda.',
        );
      }

      // 2. Cek dan minta izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const OfficeLocationCheck(
            isSuccess: false,
            errorMessage: 'Izin lokasi tidak diberikan. Berikan izin lokasi untuk verifikasi presensi.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const OfficeLocationCheck(
          isSuccess: false,
          errorMessage: 'Izin lokasi ditolak permanen. Silakan aktifkan izin lokasi di Pengaturan aplikasi.',
        );
      }

      // 3. Ambil koordinat GPS saat ini
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        // Fallback jika GPS butuh waktu lebih lama atau akurasi high time out
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        return const OfficeLocationCheck(
          isSuccess: false,
          errorMessage: 'Gagal mendapatkan koordinat GPS. Pastikan Anda berada di area dengan sinyal GPS baik.',
        );
      }

      // 4. Hitung jarak dari UTY Kampus 1
      final distance = Geolocator.distanceBetween(
        officeLatitude,
        officeLongitude,
        position.latitude,
        position.longitude,
      );

      final isWithin = distance <= maxRadiusMeters;

      return OfficeLocationCheck(
        isSuccess: true,
        position: position,
        distanceInMeters: distance,
        isWithinRadius: isWithin,
        distanceFormatted: formatDistance(distance),
      );
    } catch (e) {
      return OfficeLocationCheck(
        isSuccess: false,
        errorMessage: 'Terjadi kesalahan saat memeriksa lokasi: $e',
      );
    }
  }

  static Future<bool> openSettings() async {
    return await Geolocator.openLocationSettings();
  }

  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
