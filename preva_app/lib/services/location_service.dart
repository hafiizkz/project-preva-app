import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Cek apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi (GPS) dimatikan.');
    }

    // 2. Cek status izin
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Minta izin ke user
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Izin lokasi ditolak permanen, silakan cek pengaturan HP.');
    }

    // 3. Ambil posisi presisi tinggi
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}