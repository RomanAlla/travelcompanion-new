import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/data/services/geocoding_service.dart';

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});

