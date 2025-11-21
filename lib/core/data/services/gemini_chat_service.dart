import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<RouteModel>? routes;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.routes,
  }) : timestamp = timestamp ?? DateTime.now();
}

class GeminiChatService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1';

  String? get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    return key?.trim();
  }

  String? get _proxyUrl {
    final url = dotenv.env['GEMINI_PROXY_URL'];
    return url?.trim();
  }

  String get _requestBaseUrl {
    final proxyUrl = _proxyUrl;
    if (proxyUrl != null && proxyUrl.isNotEmpty) {
      return proxyUrl;
    }
    return _baseUrl;
  }

  Future<String> sendMessage(
    String userMessage,
    List<ChatMessage> chatHistory,
  ) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY не настроен');
    }

    try {
      final proxyUrl = _proxyUrl;
      final modelName = 'gemini-2.5-flash';

      String requestPath;
      if (proxyUrl != null && proxyUrl.isNotEmpty) {
        requestPath = '/v1/models/$modelName:generateContent';
      } else {
        requestPath = '/models/$modelName:generateContent';
      }

      final url = _requestBaseUrl + requestPath;

      final contents = <Map<String, dynamic>>[];

      // Добавляем системный промпт
      contents.add({
        'role': 'user',
        'parts': [
          {
            'text':
                'Ты умный помощник для приложения Travel Companion - приложения для создания и поиска пеших маршрутов. '
                'Твоя задача - помогать пользователям с вопросами о путешествиях, маршрутах, планировании поездок. '
                'Если пользователь просит показать или найти маршруты, система автоматически найдет подходящие маршруты и покажет их. '
                'Отвечай дружелюбно, кратко и по делу. Всегда отвечай на русском языке.',
          },
        ],
      });
      contents.add({
        'role': 'model',
        'parts': [
          {
            'text':
                'Привет! Я твой AI-помощник в Travel Companion. Готов помочь с планированием маршрутов, '
                'советами по путешествиям и ответами на вопросы о приложении. Чем могу помочь?',
          },
        ],
      });

      final recentHistory = chatHistory.length > 10
          ? chatHistory.sublist(chatHistory.length - 10)
          : chatHistory;

      for (final message in recentHistory) {
        contents.add({
          'role': message.isUser ? 'user' : 'model',
          'parts': [
            {'text': message.text},
          ],
        });
      }

      contents.add({
        'role': 'user',
        'parts': [
          {'text': userMessage},
        ],
      });

      debugPrint('Отправка сообщения в Gemini Chat...');

      final response = await _dio.post(
        url,
        queryParameters: {'key': apiKey},
        data: {
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final candidates = data['candidates'] as List?;

        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;

          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            if (text != null && text.isNotEmpty) {
              debugPrint('Получен ответ от Gemini Chat');
              return text.trim();
            }
          }
        }
      } else {
        debugPrint('Ошибка Gemini Chat API: ${response.statusCode}');
        debugPrint('Ответ: ${response.data}');

        final errorMessage =
            response.data?['error']?['message'] ??
            'Ошибка при обращении к AI. Попробуйте еще раз.';
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('Ошибка при отправке сообщения в чат: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }

    throw Exception('Не удалось получить ответ от AI');
  }

  Future<List<String>> findRelevantRoutes(
    String userQuery,
    List<RouteModel> allRoutes,
    Map<String, String> routeLocations,
    Map<String, double> routeDistances,
  ) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY не настроен');
    }

    try {
      final proxyUrl = _proxyUrl;
      final modelName = 'gemini-2.5-flash';

      String requestPath;
      if (proxyUrl != null && proxyUrl.isNotEmpty) {
        requestPath = '/v1/models/$modelName:generateContent';
      } else {
        requestPath = '/models/$modelName:generateContent';
      }

      final url = _requestBaseUrl + requestPath;

      final routesInfo = allRoutes.map((route) {
        final city = routeLocations[route.id] ?? 'неизвестно';
        final distance = routeDistances[route.id];
        final distanceText = distance != null
            ? '${distance.toStringAsFixed(1)} км от вас'
            : 'расстояние неизвестно';
        return {
          'id': route.id,
          'name': route.name,
          'description': route.description ?? '',
          'duration': route.travelDuration ?? 0,
          'city': city,
          'distance': distanceText,
        };
      }).toList();

      debugPrint('Всего маршрутов для анализа: ${routesInfo.length}');
      for (final route in routesInfo.take(5)) {
        debugPrint(
          'Маршрут: ${route['name']}, Город: ${route['city']}, ID: ${route['id']}',
        );
      }

      final prompt =
          '''
Ты помощник для приложения Travel Companion. Пользователь запросил: "$userQuery"

Вот список доступных маршрутов:
${routesInfo.map((r) => 'ID: ${r['id']}, Название: ${r['name']}, Описание: ${r['description']}, Длительность: ${r['duration']} минут, Город: ${r['city']}, Расстояние: ${r['distance']}').join('\n')}

ВАЖНО: Проанализируй запрос пользователя и найди ВСЕ маршруты, которые соответствуют запросу.
- Если пользователь упоминает город (например, "Красноярск", "Москва"), найди маршруты в этом городе
- Если пользователь упоминает близость ("рядом", "близко", "недалеко", "поблизости"), найди ближайшие маршруты (с наименьшим расстоянием)
- Если пользователь упоминает критерии (красивые, короткие, длинные), учти их
- Если город не указан, но есть другие критерии, найди маршруты по этим критериям
- Если запрос общий (например, "покажи маршруты"), верни все маршруты

Верни ТОЛЬКО JSON массив с ID маршрутов в формате: ["id1", "id2", "id3"]
Если маршруты не найдены, верни пустой массив: []
НЕ добавляй никаких пояснений, комментариев или текста - ТОЛЬКО JSON массив.
''';

      debugPrint('Анализ маршрутов для запроса: $userQuery');

      final response = await _dio.post(
        url,
        queryParameters: {'key': apiKey},
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.3,
            'topK': 20,
            'topP': 0.8,
            'maxOutputTokens': 512,
          },
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final candidates = data['candidates'] as List?;

        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;

          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            if (text != null && text.isNotEmpty) {
              debugPrint('Сырой ответ от AI: $text');
              try {
                String cleanedText = text.trim();
                cleanedText = cleanedText
                    .replaceAll(RegExp(r'```json\n?'), '')
                    .replaceAll(RegExp(r'```\n?'), '')
                    .replaceAll(RegExp(r'^\s*\[|\]\s*$'), '')
                    .trim();

                if (cleanedText.startsWith('[')) {
                  cleanedText = cleanedText.substring(1);
                }
                if (cleanedText.endsWith(']')) {
                  cleanedText = cleanedText.substring(
                    0,
                    cleanedText.length - 1,
                  );
                }
                cleanedText = '[$cleanedText]';

                debugPrint('Очищенный текст для парсинга: $cleanedText');

                try {
                  final jsonData = jsonDecode(cleanedText) as List;
                  final routeIds = jsonData
                      .map((e) => e.toString().replaceAll('"', '').trim())
                      .where((id) => id.isNotEmpty)
                      .toList();

                  debugPrint('Найдено маршрутов (JSON): ${routeIds.length}');
                  debugPrint('ID маршрутов: $routeIds');
                  return routeIds;
                } catch (jsonError) {
                  debugPrint(
                    'Не удалось распарсить как JSON, используем regex: $jsonError',
                  );
                  final matches = RegExp(r'"([^"]+)"').allMatches(text);
                  final routeIds = matches
                      .map((m) => m.group(1)!.trim())
                      .where((id) => id.isNotEmpty && id.length > 10)
                      .toList();

                  debugPrint('Найдено маршрутов (regex): ${routeIds.length}');
                  debugPrint('ID маршрутов (regex): $routeIds');
                  return routeIds;
                }
              } catch (e) {
                debugPrint('Ошибка парсинга JSON ответа: $e');
                debugPrint('Ответ AI: $text');
              }
            }
          }
        }
      } else {
        debugPrint('Ошибка при анализе маршрутов: ${response.statusCode}');
        debugPrint('Ответ: ${response.data}');
      }
    } catch (e, stackTrace) {
      debugPrint('Ошибка при поиске маршрутов: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    return [];
  }
}
