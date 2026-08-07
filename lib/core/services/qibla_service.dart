import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum QiblaPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class QiblaLocationResult {
  const QiblaLocationResult({
    required this.bearing,
    required this.locationLabel,
    required this.distanceKm,
    required this.status,
    this.latitude,
    this.longitude,
    this.declination = 0,
    this.errorMessage,
  });

  /// Absolute Qibla bearing in degrees clockwise from **true** north (0–360).
  final double bearing;
  final String locationLabel;
  final double distanceKm;
  final QiblaPermissionStatus status;
  final double? latitude;
  final double? longitude;

  /// Magnetic declination degrees East (positive) at this location.
  final double declination;
  final String? errorMessage;

  bool get hasPermission => status == QiblaPermissionStatus.granted;
}

abstract final class QiblaService {
  /// Kaaba — same coords as [Google Qibla Finder](https://support.google.com/faqs/answer/7364753).
  static const kaabaLat = 21.4224779;
  static const kaabaLng = 39.8251832;

  /// Alignment tolerance for “Qibla found” (degrees).
  static const alignmentToleranceDeg = 8.0;

  /// Relative needle angle: 0 = phone top faces Qibla.
  static double relativeNeedleDegrees(double qiblaBearing, double? trueHeading) {
    if (trueHeading == null) return qiblaBearing;
    return ((qiblaBearing - trueHeading) % 360 + 360) % 360;
  }

  /// Shortest signed offset: negative = turn left, positive = turn right.
  static double signedOffsetDegrees(double qiblaBearing, double? trueHeading) {
    if (trueHeading == null) return 0;
    var d = (qiblaBearing - trueHeading) % 360;
    if (d > 180) d -= 360;
    if (d < -180) d += 360;
    return d;
  }

  static bool isAligned(double qiblaBearing, double? trueHeading) {
    if (trueHeading == null) return false;
    return signedOffsetDegrees(qiblaBearing, trueHeading).abs() <= alignmentToleranceDeg;
  }

  static String turnInstruction(double qiblaBearing, double? trueHeading) {
    if (trueHeading == null) return 'Waiting for compass…';
    final offset = signedOffsetDegrees(qiblaBearing, trueHeading);
    if (offset.abs() <= alignmentToleranceDeg) return 'You are facing the Qibla';
    final deg = offset.abs().round();
    if (offset < 0) return 'Turn left $deg°';
    return 'Turn right $deg°';
  }

  static Future<QiblaPermissionStatus> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return QiblaPermissionStatus.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return QiblaPermissionStatus.deniedForever;
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return QiblaPermissionStatus.granted;
    }
    return QiblaPermissionStatus.denied;
  }

  static Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  static Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Great-circle initial bearing from [lat]/[lng] to Kaaba (degrees from true north).
  static double bearingToKaaba(double lat, double lng) {
    final lat1 = lat * math.pi / 180;
    final lat2 = kaabaLat * math.pi / 180;
    final dLng = (kaabaLng - lng) * math.pi / 180;
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  static double distanceToKaabaKm(double lat, double lng) {
    return Geolocator.distanceBetween(lat, lng, kaabaLat, kaabaLng) / 1000;
  }

  /// Magnetic declination (degrees East) via NOAA calculator; falls back to 0 offline.
  static Future<double> fetchDeclination(double lat, double lng) async {
    try {
      final uri = Uri.https(
        'www.ngdc.noaa.gov',
        '/geomag-web/calculators/calculateDeclination',
        {
          'lat1': lat.toStringAsFixed(4),
          'lon1': lng.toStringAsFixed(4),
          'resultFormat': 'json',
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return 0;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final result = json['result'] as List<dynamic>?;
      if (result == null || result.isEmpty) return 0;
      final declination = (result.first as Map<String, dynamic>)['declination'];
      if (declination is num) return declination.toDouble();
      return double.tryParse('$declination') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// One-shot location + Kaaba bearing (true north). Does not read compass.
  static Future<QiblaLocationResult> loadLocationBearing() async {
    final status = await ensurePermission();
    if (status != QiblaPermissionStatus.granted) {
      final message = switch (status) {
        QiblaPermissionStatus.serviceDisabled =>
          'Turn on location services to find Qibla.',
        QiblaPermissionStatus.deniedForever =>
          'Location access is blocked. Enable it in system settings.',
        _ => 'Location permission is needed to find Qibla.',
      };
      return QiblaLocationResult(
        bearing: 0,
        locationLabel: 'Location unavailable',
        distanceKm: 0,
        status: status,
        errorMessage: message,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final bearing = bearingToKaaba(position.latitude, position.longitude);
      final declination = await fetchDeclination(position.latitude, position.longitude);
      return QiblaLocationResult(
        bearing: bearing,
        locationLabel:
            '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}',
        distanceKm: distanceToKaabaKm(position.latitude, position.longitude),
        status: QiblaPermissionStatus.granted,
        latitude: position.latitude,
        longitude: position.longitude,
        declination: declination,
      );
    } catch (_) {
      return QiblaLocationResult(
        bearing: 0,
        locationLabel: 'Location unavailable',
        distanceKm: 0,
        status: QiblaPermissionStatus.denied,
        errorMessage: 'Could not get your location. Try again outdoors.',
      );
    }
  }

  /// Live **true** heading (magnetic heading + declination). Null events skipped.
  static Stream<double>? headingStream({double declination = 0}) {
    final events = FlutterCompass.events;
    if (events == null) return null;
    return events
        .map((e) => e.heading)
        .where((h) => h != null)
        .cast<double>()
        .map((magnetic) {
          // Compass reports magnetic north; Qibla bearing is from true north.
          // true = magnetic + declination (East-positive NOAA convention).
          final trueHeading = (magnetic + declination) % 360;
          return (trueHeading + 360) % 360;
        });
  }

  static bool get isCompassAvailable => FlutterCompass.events != null;

  static String directionLabel(double bearing) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) % 360 / 45).floor();
    return '${bearing.round()}° ${dirs[index]}';
  }
}
