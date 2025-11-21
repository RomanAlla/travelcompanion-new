import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/data/services/gemini_chat_service.dart';

final geminiChatServiceProvider = Provider<GeminiChatService>((ref) {
  return GeminiChatService();
});

