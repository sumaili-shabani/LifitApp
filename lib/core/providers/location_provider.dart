import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location_service;

final locationProvider =
    StateNotifierProvider<LocationNotifier, LatLng?>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<LatLng?> {
  LocationNotifier() : super(null) {
    _initLocation();
  }

  final location_service.Location _location = location_service.Location();

  Future<void> _initLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    location_service.PermissionStatus permissionGranted =
        await _location.hasPermission();
    if (permissionGranted == location_service.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != location_service.PermissionStatus.granted)
        return;
    }

    _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        state = LatLng(locationData.latitude!, locationData.longitude!);
      }
    });

    final locationData = await _location.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      state = LatLng(locationData.latitude!, locationData.longitude!);
    }
  }
}
