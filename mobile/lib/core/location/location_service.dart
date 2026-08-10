import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Casablanca city center — used whenever we can't get a real position
/// (permission denied, location services off, or a timeout).
const LatLng defaultFallbackPosition = LatLng(33.5731, -7.5898);

class LocationResult {
  const LocationResult({required this.position, required this.isPrecise});

  final LatLng position;

  /// False when [position] is the fallback default rather than a real fix.
  final bool isPrecise;
}

class LocationService {
  Future<LocationResult> resolveCurrentPosition() async {
    try {
      // Ask for permission first — this dialog is independent of whether the
      // device's Location toggle is currently on, so it must not be skipped
      // just because location services happen to be off right now.
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return const LocationResult(position: defaultFallbackPosition, isPrecise: false);
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(position: defaultFallbackPosition, isPrecise: false);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LocationResult(position: LatLng(position.latitude, position.longitude), isPrecise: true);
    } catch (_) {
      return const LocationResult(position: defaultFallbackPosition, isPrecise: false);
    }
  }
}

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
