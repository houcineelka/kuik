import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/location/location_service.dart';

/// A "drag the map under a fixed pin" position picker — the pin never
/// moves, the map does, and the pin's coordinates are the map center.
class PositionPickerMap extends StatefulWidget {
  const PositionPickerMap({
    super.key,
    required this.initialPosition,
    required this.onPositionChanged,
  });

  final LatLng initialPosition;
  final ValueChanged<LatLng> onPositionChanged;

  @override
  State<PositionPickerMap> createState() => _PositionPickerMapState();
}

class _PositionPickerMapState extends State<PositionPickerMap> {
  final _mapController = MapController();
  late LatLng _center = widget.initialPosition;
  bool _locating = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    final result = await LocationService().resolveCurrentPosition();
    if (!mounted) return;
    setState(() {
      _locating = false;
      _center = result.position;
    });
    _mapController.move(result.position, 15);
    widget.onPositionChanged(result.position);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 15,
                onPositionChanged: (camera, hasGesture) {
                  _center = camera.center;
                  if (hasGesture) widget.onPositionChanged(camera.center);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kuik.mobile',
                ),
              ],
            ),
            IgnorePointer(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Icon(Icons.location_pin, size: 40, color: scheme.primary),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: FloatingActionButton.small(
                heroTag: 'position-picker-locate',
                onPressed: _locating ? null : _useCurrentLocation,
                backgroundColor: scheme.surfaceContainerLowest,
                foregroundColor: scheme.primary,
                child: _locating
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary),
                      )
                    : const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
