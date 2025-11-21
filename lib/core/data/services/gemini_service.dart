import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Сервис для работы с Google Gemini API
class GeminiService {
  final Dio _dio = Dio();
  // Базовый URL для Gemini API
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1';

  /// Получить API ключ из .env
  String? get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    // Убираем пробелы в начале и конце, если есть
    return key?.trim();
  }

  /// Получить URL прокси из .env (Cloudflare Worker)
  String? get _proxyUrl {
    final url = dotenv.env['GEMINI_PROXY_URL'];
    return url?.trim();
  }

  /// Получить базовый URL для запросов (прокси или прямой)
  String get _requestBaseUrl {
    final proxyUrl = _proxyUrl;
    if (proxyUrl != null && proxyUrl.isNotEmpty) {
      // Если используется прокси, убираем базовый URL из пути
      return proxyUrl;
    }
    return _baseUrl;
  }

  /// Генерация умных советов на основе маршрута
  ///
  /// Анализирует точки маршрута и предлагает советы по:
  /// - Погоде
  /// - Что взять с собой
  /// - Где перекусить
  /// - Другим полезным рекомендациям
  Future<List<String>> generateRouteTips({
    required Point startPoint,
    required Point endPoint,
    List<Point>? wayPoints,
    String? routeName,
    int? travelDuration,
  }) async {
    final apiKey = _apiKey;
    debugPrint(
      'GEMINI_API_KEY check: ${apiKey != null ? "found (length: ${apiKey.length})" : "null"}',
    );

    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('GEMINI_API_KEY не найден в .env файле');
      throw Exception('GEMINI_API_KEY не настроен');
    }

    try {
      // Формируем промпт для Gemini
      final prompt = _buildPrompt(
        startPoint: startPoint,
        endPoint: endPoint,
        wayPoints: wayPoints,
        routeName: routeName,
        travelDuration: travelDuration,
      );

      debugPrint('Отправка запроса к Gemini API...');
      final proxyUrl = _proxyUrl;
      if (proxyUrl != null && proxyUrl.isNotEmpty) {
        debugPrint('Используется прокси: $proxyUrl');
      } else {
        debugPrint('Используется прямой доступ к API');
      }

      final modelName = 'gemini-2.5-flash';

      String requestPath;
      if (proxyUrl != null && proxyUrl.isNotEmpty) {
        requestPath = '/v1/models/$modelName:generateContent';
      } else {
        requestPath = '/models/$modelName:generateContent';
      }

      final url = _requestBaseUrl + requestPath;

      debugPrint('URL: $url');
      debugPrint('API Key length: ${apiKey.length}');

      final headers = <String, String>{'Content-Type': 'application/json'};

      final queryParams = <String, dynamic>{'key': apiKey};

      final response = await _dio.post(
        url,
        queryParameters: queryParams,
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        },
        options: Options(
          headers: headers,
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
              debugPrint('Получен ответ от Gemini API');
              return _parseTips(text);
            }
          }
        }
      } else {
        debugPrint('Ошибка Gemini API: ${response.statusCode}');
        debugPrint('Ответ: ${response.data}');

        if (response.statusCode == 404) {
          try {
            String modelsPath;
            if (proxyUrl != null && proxyUrl.isNotEmpty) {
              modelsPath = '/v1/models';
            } else {
              modelsPath = '/models';
            }
            final modelsResponse = await _dio.get(
              _requestBaseUrl + modelsPath,
              queryParameters: {'key': apiKey},
            );
            debugPrint('Доступные модели: ${modelsResponse.data}');
          } catch (e) {
            debugPrint('Не удалось получить список моделей: $e');
          }
        }

        final errorMessage =
            response.data?['error']?['message'] ??
            'Ошибка при обращении к Gemini API: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('Ошибка при генерации советов: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }

    return [];
  }

  String _buildPrompt({
    required Point startPoint,
    required Point endPoint,
    List<Point>? wayPoints,
    String? routeName,
    int? travelDuration,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(
      'Ты помощник для приложения Travel Companion. Проанализируй маршрут и предложи полезные советы.',
    );
    buffer.writeln();
    buffer.writeln('Информация о маршруте:');

    if (routeName != null && routeName.isNotEmpty) {
      buffer.writeln('- Название: $routeName');
    }

    buffer.writeln(
      '- Начальная точка: ${startPoint.latitude}, ${startPoint.longitude}',
    );
    buffer.writeln(
      '- Конечная точка: ${endPoint.latitude}, ${endPoint.longitude}',
    );

    if (wayPoints != null && wayPoints.isNotEmpty) {
      buffer.writeln('- Промежуточных точек: ${wayPoints.length}');
    }

    if (travelDuration != null) {
      final hours = travelDuration ~/ 60;
      final minutes = travelDuration % 60;
      buffer.writeln('- Продолжительность: $hoursч $minutesмин');
    }

    buffer.writeln();
    buffer.writeln(
      'Предложи 5-7 полезных советов для этого пешего маршрута. Включи:',
    );
    buffer.writeln('1. Рекомендации по погоде (что ожидать, как одеваться)');
    buffer.writeln('2. Что взять с собой (необходимые вещи)');
    buffer.writeln('3. Где можно перекусить (рекомендации по кафе/ресторанам)');
    buffer.writeln('4. Безопасность и удобство маршрута');
    buffer.writeln('5. Дополнительные полезные советы');
    buffer.writeln();
    buffer.writeln('Важно:');
    buffer.writeln('- Отвечай ТОЛЬКО на русском языке');
    buffer.writeln('- Каждый совет должен быть кратким (1-2 предложения)');
    buffer.writeln('- Советы должны быть практичными и полезными');
    buffer.writeln(
      '- Форматируй ответ как список, где каждый совет на новой строке',
    );
    buffer.writeln(
      '- НЕ используй нумерацию или маркеры, просто текст каждого совета на новой строке',
    );
    buffer.writeln();
    buffer.writeln('Начни сразу с советов, без вводных слов:');

    return buffer.toString();
  }

  List<String> _parseTips(String text) {
    final tips = <String>[];

    final lines = text.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.isEmpty ||
          trimmed.length < 10 ||
          trimmed.startsWith('*') ||
          trimmed.startsWith('-') ||
          trimmed.startsWith('•') ||
          RegExp(r'^\d+[\.\)]').hasMatch(trimmed)) {
        continue;
      }

      final cleaned = trimmed.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '');

      final finalTip = cleaned.replaceFirst(RegExp(r'^[-\*•]\s*'), '').trim();

      if (finalTip.isNotEmpty && finalTip.length >= 10) {
        tips.add(finalTip);
      }
    }

    if (tips.isEmpty && text.trim().isNotEmpty) {
      tips.add(text.trim());
    }

    return tips.take(7).toList();
  }
}
