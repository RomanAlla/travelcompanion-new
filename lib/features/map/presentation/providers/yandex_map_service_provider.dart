import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/map/data/services/yandex_map_service.dart';

final yandexMapServiceProvider = Provider<YandexMapService>((ref) {
  return YandexMapService();
});
