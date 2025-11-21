import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/data/services/gemini_service.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

