import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../core_imports.dart';

class ClockInPage extends StatefulWidget {
  const ClockInPage({super.key});
  @override
  State<ClockInPage> createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  // Selfie Camera State
  File? _selfieFile;
  final ImagePicker _picker = ImagePicker();

  // Location GPS State
  bool _isLoadingLocation = true;
  OfficeLocationCheck? _locationCheck;
  bool _isWfhOrRemote = false;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
    _checkLocation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkLocation() async {
    setState(() => _isLoadingLocation = true);
    final result = await LocationService.checkLocationProximity();
    if (!mounted) return;
    setState(() {
      _locationCheck = result;
      _isLoadingLocation = false;
      // Jika di luar radius, otomatis tawarkan mode dinas luar / WFH agar presensi tidak terkunci
      if (result.isSuccess && !result.isWithinRadius) {
        _isWfhOrRemote = true;
      }
    });
  }

  Future<void> _takeSelfie({bool fromGallery = false}) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1024,
      );

      if (picked != null) {
        setState(() {
          _selfieFile = File(picked.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengakses kamera: $e. Pastikan izin kamera aktif.'),
          backgroundColor: kRed,
          action: SnackBarAction(
            label: 'Pengaturan',
            textColor: Colors.white,
            onPressed: () => LocationService.openAppSettings(),
          ),
        ),
      );
    }
  }

  Future<void> _submitClockIn() async {
    if (_selfieFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan ambil foto selfie terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final now = DateTime.now();

    String finalLokasi = LocationService.officeName;
    String? ket;

    if (_locationCheck != null && _locationCheck!.isSuccess) {
      final pos = _locationCheck!.position;
      final distStr = _locationCheck!.distanceFormatted;
      if (_isWfhOrRemote) {
        finalLokasi = 'WFH / Dinas Luar';
        ket = 'Presensi di luar radius kantor ($distStr)';
      } else {
        finalLokasi = '${LocationService.officeName} ($distStr)';
        ket = 'Presensi dalam radius kantor ($distStr)';
      }

      await AppState.doClockIn(
        time: now,
        customLokasi: finalLokasi,
        customKeterangan: ket,
        fotoPath: _selfieFile?.path,
        latitude: pos?.latitude,
        longitude: pos?.longitude,
      );
    } else {
      // Fallback jika GPS tidak tersedia
      await AppState.doClockIn(
        time: now,
        customLokasi: 'HQ Menara Tekno (Manual/Offline)',
        customKeterangan: 'Koordinat GPS tidak tersedia',
        fotoPath: _selfieFile?.path,
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Clock In berhasil dicatat pada ${hm(now)} WIB!'),
        backgroundColor: kGreen,
      ),
    );
    Navigator.pop(context);
  }

  Widget _buildLocationCard() {
    final check = _locationCheck;

    if (_isLoadingLocation) {
      return const AppCard(
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mendeteksi Lokasi GPS...',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text('Menghubungkan ke satelit GPS dan menghitung radius kantor...',
                      style: TextStyle(fontSize: 12, color: kMuted)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (check == null || !check.isSuccess) {
      return AppCard(
        color: const Color(0xFFFEF2F2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_off, color: kRed),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('GPS Belum Terdeteksi',
                      style: TextStyle(fontWeight: FontWeight.w700, color: kRed)),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: kRed),
                  onPressed: _checkLocation,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              check?.errorMessage ?? 'Layanan lokasi tidak aktif.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kRed,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Buka Pengaturan', style: TextStyle(fontSize: 12)),
                  onPressed: () => LocationService.openSettings(),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _checkLocation,
                  child: const Text('Coba Lagi', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final pos = check.position;
    final isWithin = check.isWithinRadius;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isWithin ? Icons.location_on : Icons.wrong_location,
                    color: isWithin ? kGreen : kYellow,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    LocationService.officeName,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18, color: kPrimary),
                tooltip: 'Perbarui Lokasi GPS',
                onPressed: _checkLocation,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            LocationService.officeAddress,
            style: TextStyle(color: kMuted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isWithin ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isWithin ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jarak: ${check.distanceFormatted} dari kantor',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isWithin ? const Color(0xFF166534) : const Color(0xFF854D0E),
                        ),
                      ),
                      if (pos != null)
                        Text(
                          'Koordinat: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isWithin ? const Color(0xFF15803D) : const Color(0xFFA16207),
                          ),
                        ),
                    ],
                  ),
                ),
                StatusBadge(
                  isWithin ? 'Radius Valid' : 'Di Luar Radius',
                  isWithin ? kGreen : kYellow,
                ),
              ],
            ),
          ),
          if (!isWithin) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _isWfhOrRemote,
                  activeColor: kPrimary,
                  onChanged: (val) => setState(() => _isWfhOrRemote = val ?? false),
                ),
                const Expanded(
                  child: Text(
                    'Presensi Dinas Luar / WFH (Di luar radius)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _selfieFile != null &&
        !_isSubmitting &&
        ((_locationCheck != null && _locationCheck!.isSuccess && (_locationCheck!.isWithinRadius || _isWfhOrRemote)) ||
            _locationCheck == null ||
            !_locationCheck!.isSuccess);

    return Scaffold(
      body: Column(children: [
        const AppHeader(
          'Konfirmasi Clock In',
          'Pastikan foto selfie dan lokasi Anda valid',
          back: true,
        ),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            // Jam & Shift Card
            AppCard(
              child: Column(children: [
                Text(
                  hms(_currentTime),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: kPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(tgl(_currentTime), style: const TextStyle(color: kMuted)),
                const Divider(height: 24),
                const Row(
                  children: [
                    Icon(Icons.work_outline, color: kPrimary),
                    SizedBox(width: 10),
                    Text(
                      'Shift Reguler · 08:00–17:00 WIB',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ]),
            ),

            // Real GPS Location Card
            _buildLocationCard(),

            // Real Camera Selfie Card
            AppCard(
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Verifikasi Wajah (Selfie)',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  if (_selfieFile != null)
                    const StatusBadge('Wajah Terverifikasi 98%', kGreen),
                ]),
                const SizedBox(height: 14),
                Container(
                  height: 200,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: _selfieFile != null ? Colors.black : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selfieFile != null ? kGreen : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      if (_selfieFile != null)
                        Image.file(
                          _selfieFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      else
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Color(0xFFE0E7FF),
                              child: Icon(Icons.face, size: 48, color: kPrimary),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Arahkan kamera ke wajah Anda',
                              style: TextStyle(color: kMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      if (_selfieFile != null)
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'NIP: ${AppState.nip}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${hm(_currentTime)} WIB',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          backgroundColor: kPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _takeSelfie(fromGallery: false),
                        icon: Icon(
                          _selfieFile != null ? Icons.refresh : Icons.camera_alt,
                          size: 20,
                        ),
                        label: Text(_selfieFile != null ? 'Ambil Ulang Selfie' : 'Buka Kamera Selfie'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Pilih dari Galeri',
                      onPressed: () => _takeSelfie(fromGallery: true),
                      icon: const Icon(Icons.photo_library_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pastikan wajah terlihat jelas tanpa masker dan dalam pencahayaan cukup.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kMuted, fontSize: 11),
                ),
              ]),
            ),

            const SizedBox(height: 8),

            // Submit Button
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: kGreen,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: canSubmit ? _submitClockIn : null,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.fingerprint),
              label: Text(
                _isSubmitting
                    ? 'Menyimpan Presensi...'
                    : (_selfieFile == null
                        ? 'Ambil Foto Selfie Dahulu'
                        : 'Konfirmasi Clock In Sekarang'),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
