import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/presentation/providers/geocoding_service_provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Провайдер для получения адреса по координатам с кэшированием
final addressProvider = FutureProvider.family<String, Point>((ref, point) async {
  final geocodingService = ref.watch(geocodingServiceProvider);
  return await geocodingService.getAddressFromCoordinates(point);
});

