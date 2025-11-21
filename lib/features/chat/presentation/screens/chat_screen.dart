import 'dart:math' as math;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travelcompanion/core/data/services/gemini_chat_service.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/presentation/providers/gemini_chat_service_provider.dart';
import 'package:travelcompanion/core/presentation/providers/geocoding_service_provider.dart';
import 'package:travelcompanion/core/presentation/router/router.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_point_repository_provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

@RoutePage()
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Кэш для городов маршрутов (routeId -> city)
  final Map<String, String> _routeCitiesCache = {};

  // Популярные запросы для быстрого доступа
  final List<Map<String, String>> _quickActions = [
    {
      'title': 'Маршруты рядом',
      'query': 'найди маршруты по близости',
      'icon': 'location_on',
    },
    {
      'title': 'Красивые маршруты',
      'query': 'покажи красивые маршруты',
      'icon': 'photo',
    },
    {
      'title': 'Короткие маршруты',
      'query': 'найди короткие маршруты',
      'icon': 'timer',
    },
    {
      'title': 'Длинные маршруты',
      'query': 'покажи длинные маршруты',
      'icon': 'route',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Добавляем приветственное сообщение
    _messages.add(
      ChatMessage(
        text:
            'Привет! Я твой AI-помощник в Travel Companion. Могу помочь с планированием маршрутов, '
            'советами по путешествиям и ответами на вопросы. Чем могу помочь?',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? messageText]) async {
    final text = messageText ?? _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Очищаем поле ввода, если сообщение было введено вручную
    if (messageText == null) {
      _messageController.clear();
    }

    // Добавляем сообщение пользователя
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    // Прокручиваем к последнему сообщению
    _scrollToBottom();

    try {
      final chatService = ref.read(geminiChatServiceProvider);
      final routeRepository = ref.read(routeRepositoryProvider);

      // Проверяем, является ли запрос запросом о маршрутах
      final isRouteQuery = _isRouteQuery(text);

      if (isRouteQuery) {
        // Получаем все маршруты
        final allRoutes = await routeRepository.getRoutes();
        debugPrint('Всего маршрутов: ${allRoutes.length}');

        // Проверяем, упоминается ли город в запросе
        final lowerQuery = text.toLowerCase();
        final cityKeywords = [
          'красноярск',
          'москва',
          'санкт-петербург',
          'спб',
          'питер',
        ];
        final mentionedCity = cityKeywords.firstWhere(
          (city) => lowerQuery.contains(city),
          orElse: () => '',
        );

        // Проверяем, упоминается ли поиск по близости
        final proximityKeywords = [
          'рядом',
          'близко',
          'недалеко',
          'поблизости',
          'около',
          'близости',
        ];
        final isProximityQuery = proximityKeywords.any(
          (keyword) => lowerQuery.contains(keyword),
        );

        debugPrint('Запрос: "$text"');
        debugPrint('Определен как запрос по близости: $isProximityQuery');

        // Получаем текущее местоположение, если нужен поиск по близости
        Position? userLocation;
        if (isProximityQuery) {
          debugPrint(
            'Запрос по близости обнаружен, получаем местоположение...',
          );
          userLocation = await _getCurrentLocation();
          if (userLocation != null) {
            debugPrint(
              'Местоположение пользователя: ${userLocation.latitude}, ${userLocation.longitude}',
            );
          } else {
            debugPrint(
              'ОШИБКА: Не удалось получить местоположение пользователя',
            );
          }
        } else {
          debugPrint('Запрос по близости не обнаружен');
        }

        // Ограничиваем количество маршрутов для анализа (максимум 100)
        const maxRoutesToAnalyze = 100;
        final routesToAnalyze = allRoutes.take(maxRoutesToAnalyze).toList();
        debugPrint('Анализируем маршрутов: ${routesToAnalyze.length}');

        // Получаем информацию о городах для маршрутов параллельно
        final routePointRepository = ref.read(routePointRepositoryProvider);
        final geocodingService = ref.read(geocodingServiceProvider);
        final routeLocations = <String, String>{};

        // Сначала проверяем кэш и получаем города только для тех маршрутов, которых нет в кэше
        final routesToFetch = routesToAnalyze
            .where((route) => !_routeCitiesCache.containsKey(route.id))
            .toList();

        debugPrint(
          'Кэш: ${routesToAnalyze.length - routesToFetch.length} из ${routesToAnalyze.length} маршрутов уже в кэше',
        );

        // Создаем список Future для параллельного выполнения (только для маршрутов не в кэше)
        final futures = routesToFetch.map((route) async {
          try {
            final startPoint = await routePointRepository.getStartPoint(
              id: route.id,
            );
            final address = await geocodingService.getAddressFromCoordinates(
              Point(
                latitude: startPoint.latitude,
                longitude: startPoint.longitude,
              ),
            );
            final city = _extractCityFromAddress(address);
            // Сохраняем в кэш
            _routeCitiesCache[route.id] = city;
            return MapEntry(route.id, city);
          } catch (e) {
            debugPrint('Ошибка получения города для маршрута ${route.id}: $e');
            final city = 'неизвестно';
            _routeCitiesCache[route.id] = city;
            return MapEntry(route.id, city);
          }
        }).toList();

        // Выполняем все запросы параллельно
        if (futures.isNotEmpty) {
          final results = await Future.wait(futures);
          routeLocations.addAll(Map.fromEntries(results));
        }

        // Добавляем города из кэша
        for (final route in routesToAnalyze) {
          if (_routeCitiesCache.containsKey(route.id)) {
            routeLocations[route.id] = _routeCitiesCache[route.id]!;
          }
        }

        debugPrint('Получено городов для маршрутов: ${routeLocations.length}');

        // Вычисляем расстояния до маршрутов, если нужен поиск по близости
        final routeDistances = <String, double>{};
        if (isProximityQuery && userLocation != null) {
          // Сохраняем координаты пользователя в локальные переменные
          final userLat = userLocation.latitude;
          final userLon = userLocation.longitude;

          // Вычисляем расстояния параллельно
          final distanceFutures = routesToAnalyze.map((route) async {
            try {
              final startPoint = await routePointRepository.getStartPoint(
                id: route.id,
              );
              final distance = _calculateDistance(
                userLat,
                userLon,
                startPoint.latitude,
                startPoint.longitude,
              );
              return MapEntry(route.id, distance);
            } catch (e) {
              debugPrint(
                'Ошибка вычисления расстояния для маршрута ${route.id}: $e',
              );
              return MapEntry(route.id, double.infinity);
            }
          }).toList();

          final distanceResults = await Future.wait(distanceFutures);
          routeDistances.addAll(Map.fromEntries(distanceResults));
          debugPrint('Вычислено расстояний: ${routeDistances.length}');
        }

        // Если упоминается город, сначала пробуем быстрый поиск по уже полученным городам
        var foundRoutes = <RouteModel>[];
        if (mentionedCity.isNotEmpty) {
          debugPrint('Быстрый поиск: ищем маршруты в городе $mentionedCity');
          foundRoutes = routesToAnalyze.where((route) {
            final routeCity = routeLocations[route.id]?.toLowerCase() ?? '';
            return routeCity.contains(mentionedCity);
          }).toList();
          debugPrint('Быстрый поиск нашел маршрутов: ${foundRoutes.length}');
        }

        // Если нужен поиск по близости, фильтруем по расстоянию
        if (isProximityQuery && userLocation != null && foundRoutes.isEmpty) {
          debugPrint('Поиск по близости');
          debugPrint('Доступно расстояний: ${routeDistances.length}');

          if (routeDistances.isEmpty) {
            debugPrint('ОШИБКА: Расстояния не вычислены!');
          } else {
            // Показываем первые несколько расстояний для отладки
            final sampleDistances = routeDistances.entries.take(5).toList();
            for (final entry in sampleDistances) {
              debugPrint(
                'Маршрут ${entry.key}: ${entry.value.toStringAsFixed(2)} км',
              );
            }
          }

          // Сортируем маршруты по расстоянию и берем ближайшие
          // Используем динамический радиус: если маршрутов мало, увеличиваем радиус
          double searchRadius = 50; // Начальный радиус 50 км
          var nearbyRoutes = routesToAnalyze.where((route) {
            final distance = routeDistances[route.id];
            if (distance == null) {
              debugPrint('Маршрут ${route.id}: расстояние не найдено');
              return false;
            }
            final isNearby = distance <= searchRadius;
            if (isNearby) {
              debugPrint(
                'Маршрут ${route.id} в радиусе: ${distance.toStringAsFixed(2)} км',
              );
            }
            return isNearby;
          }).toList();

          // Если маршрутов мало, увеличиваем радиус
          if (nearbyRoutes.length < 5) {
            searchRadius = 100; // Увеличиваем до 100 км
            debugPrint('Мало маршрутов в радиусе 50 км, увеличиваем до 100 км');
            nearbyRoutes = routesToAnalyze.where((route) {
              final distance = routeDistances[route.id];
              return distance != null && distance <= searchRadius;
            }).toList();
          }

          if (nearbyRoutes.length < 3) {
            searchRadius = 200; // Увеличиваем до 200 км
            debugPrint(
              'Мало маршрутов в радиусе 100 км, увеличиваем до 200 км',
            );
            nearbyRoutes = routesToAnalyze.where((route) {
              final distance = routeDistances[route.id];
              return distance != null && distance <= searchRadius;
            }).toList();
          }

          debugPrint(
            'Найдено маршрутов в радиусе $searchRadius км: ${nearbyRoutes.length}',
          );

          // Сортируем по расстоянию
          nearbyRoutes.sort((a, b) {
            final distA = routeDistances[a.id] ?? double.infinity;
            final distB = routeDistances[b.id] ?? double.infinity;
            return distA.compareTo(distB);
          });

          foundRoutes = nearbyRoutes.take(10).toList(); // Берем 10 ближайших
          debugPrint(
            'Найдено маршрутов поблизости (после сортировки): ${foundRoutes.length}',
          );
        }

        // Если быстрый поиск не дал результатов или город не упомянут, используем AI
        if (foundRoutes.isEmpty) {
          debugPrint('Быстрый поиск не дал результатов, используем AI');
          // Анализируем запрос и находим подходящие маршруты через AI
          final routeIds = await chatService.findRelevantRoutes(
            text,
            routesToAnalyze,
            routeLocations,
            routeDistances,
          );

          debugPrint('AI нашел маршрутов: ${routeIds.length}');
          debugPrint('ID найденных маршрутов: $routeIds');

          // Фильтруем маршруты по найденным ID
          foundRoutes = routesToAnalyze
              .where((route) => routeIds.contains(route.id))
              .toList();

          // Fallback: если AI не нашел, используем простую фильтрацию
          if (foundRoutes.isEmpty) {
            debugPrint('Fallback: AI не нашел, используем простую фильтрацию');
            foundRoutes = _simpleRouteFilter(text, routesToAnalyze);
            debugPrint('Fallback нашел маршрутов: ${foundRoutes.length}');
          }

          // Дополнительный fallback для запросов по близости
          if (foundRoutes.isEmpty &&
              isProximityQuery &&
              routeDistances.isNotEmpty) {
            debugPrint(
              'Fallback по близости: используем ближайшие маршруты (независимо от радиуса)',
            );
            final sortedRoutes = List<RouteModel>.from(routesToAnalyze);
            sortedRoutes.sort((a, b) {
              final distA = routeDistances[a.id] ?? double.infinity;
              final distB = routeDistances[b.id] ?? double.infinity;
              return distA.compareTo(distB);
            });
            // Берем 10 ближайших, даже если они далеко
            foundRoutes = sortedRoutes
                .where((route) => routeDistances[route.id] != null)
                .take(10)
                .toList();
            debugPrint(
              'Fallback по близости нашел маршрутов: ${foundRoutes.length}',
            );
            if (foundRoutes.isNotEmpty) {
              final firstDistance = routeDistances[foundRoutes.first.id];
              debugPrint(
                'Ближайший маршрут на расстоянии: ${firstDistance?.toStringAsFixed(2)} км',
              );
            }
          }
        }

        // Формируем ответ
        String responseText;
        if (foundRoutes.isEmpty) {
          responseText =
              'К сожалению, я не нашел маршруты, соответствующие вашему запросу. Попробуйте уточнить критерии поиска.';
        } else {
          responseText =
              'Нашел ${foundRoutes.length} ${foundRoutes.length == 1
                  ? 'маршрут'
                  : foundRoutes.length < 5
                  ? 'маршрута'
                  : 'маршрутов'}, которые могут вас заинтересовать:';
        }

        setState(() {
          _messages.add(
            ChatMessage(
              text: responseText,
              isUser: false,
              routes: foundRoutes.isNotEmpty ? foundRoutes : null,
            ),
          );
          _isLoading = false;
        });
      } else {
        // Обычный ответ от AI
        final response = await chatService.sendMessage(text, _messages);

        setState(() {
          _messages.add(ChatMessage(text: response, isUser: false));
          _isLoading = false;
        });
      }

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Извините, произошла ошибка: ${e.toString()}',
            isUser: false,
          ),
        );
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  /// Проверяет, является ли запрос запросом о маршрутах
  bool _isRouteQuery(String query) {
    final lowerQuery = query.toLowerCase();
    final routeKeywords = [
      'покажи',
      'найди',
      'найти',
      'ищу',
      'искать',
      'маршрут',
      'маршруты',
      'путь',
      'пути',
      'прогулка',
      'прогулки',
      'красноярск',
      'москва',
      'санкт-петербург',
      'красив',
      'интересн',
      'коротк',
      'длинн',
      'рядом',
      'близко',
      'недалеко',
      'поблизости',
      'около',
    ];

    return routeKeywords.any((keyword) => lowerQuery.contains(keyword));
  }

  /// Вычисляет расстояние между двумя точками в километрах (формула Haversine)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Радиус Земли в километрах

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Получает текущее местоположение пользователя
  Future<Position?> _getCurrentLocation() async {
    try {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        debugPrint('Разрешение на геолокацию не предоставлено');
        return null;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Службы геолокации отключены');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      return position;
    } catch (e) {
      debugPrint('Ошибка получения местоположения: $e');
      return null;
    }
  }

  /// Простая фильтрация маршрутов по ключевым словам (fallback)
  List<RouteModel> _simpleRouteFilter(String query, List<RouteModel> routes) {
    final lowerQuery = query.toLowerCase();
    final filteredRoutes = <RouteModel>[];

    // Фильтр по длительности
    if (lowerQuery.contains('длинн') || lowerQuery.contains('долг')) {
      // Сортируем по длительности (от большего к меньшему)
      final sorted = List<RouteModel>.from(routes);
      sorted.sort((a, b) {
        final durA = a.travelDuration ?? 0;
        final durB = b.travelDuration ?? 0;
        return durB.compareTo(durA); // Обратный порядок для длинных
      });
      filteredRoutes.addAll(sorted.take(10));
      debugPrint(
        'Простая фильтрация: найдено длинных маршрутов: ${filteredRoutes.length}',
      );
    } else if (lowerQuery.contains('коротк')) {
      // Сортируем по длительности (от меньшего к большему)
      final sorted = List<RouteModel>.from(routes);
      sorted.sort((a, b) {
        final durA = a.travelDuration ?? 0;
        final durB = b.travelDuration ?? 0;
        return durA.compareTo(durB);
      });
      filteredRoutes.addAll(sorted.take(10));
      debugPrint(
        'Простая фильтрация: найдено коротких маршрутов: ${filteredRoutes.length}',
      );
    } else if (lowerQuery.contains('красив') ||
        lowerQuery.contains('интересн')) {
      // Для красивых/интересных берем маршруты с фотографиями или описанием
      filteredRoutes.addAll(
        routes
            .where((route) {
              return (route.photoUrls.isNotEmpty) ||
                  (route.description != null && route.description!.isNotEmpty);
            })
            .take(10),
      );
      debugPrint(
        'Простая фильтрация: найдено красивых маршрутов: ${filteredRoutes.length}',
      );
    } else {
      // Если нет специфических критериев, возвращаем все маршруты
      filteredRoutes.addAll(routes.take(10));
      debugPrint(
        'Простая фильтрация: возвращаем все маршруты: ${filteredRoutes.length}',
      );
    }

    return filteredRoutes;
  }

  /// Извлекает город из адреса
  String _extractCityFromAddress(String address) {
    debugPrint('Извлечение города из адреса: $address');

    // Адрес обычно имеет формат: "улица, дом, город, страна"
    // Или "город, страна"
    final parts = address.split(',').map((e) => e.trim()).toList();

    // Список ключевых слов, которые указывают на страну/регион, а не город
    final countryKeywords = [
      'россия',
      'russia',
      'край',
      'область',
      'республика',
    ];

    // Пробуем найти город (обычно предпоследний элемент, если есть страна)
    if (parts.length >= 2) {
      // Если последний элемент похож на страну/регион
      final lastPart = parts.last.toLowerCase();
      final isCountry = countryKeywords.any(
        (keyword) => lastPart.contains(keyword),
      );

      if (isCountry && parts.length >= 2) {
        // Предпоследний элемент - вероятно город
        final city = parts[parts.length - 2];
        debugPrint('Извлеченный город: $city');
        return city;
      }

      // Если последний элемент не страна, проверяем предпоследний
      if (parts.length >= 3) {
        final secondLast = parts[parts.length - 2].toLowerCase();
        final isSecondLastCountry = countryKeywords.any(
          (keyword) => secondLast.contains(keyword),
        );

        if (isSecondLastCountry) {
          // Третий с конца - вероятно город
          final city = parts[parts.length - 3];
          debugPrint('Извлеченный город (3-й с конца): $city');
          return city;
        }
      }

      // Если нет явной страны, берем последний элемент
      final city = parts.last;
      debugPrint('Извлеченный город (последний элемент): $city');
      return city;
    }

    // Если не удалось извлечь, возвращаем весь адрес
    debugPrint('Не удалось извлечь город, возвращаем весь адрес');
    return address;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Проверяет, нужно ли показывать кнопки быстрых действий
  bool _shouldShowQuickActions() {
    // Показываем кнопки, если:
    // 1. Нет загрузки
    // 2. Есть только приветственное сообщение или последнее сообщение от AI
    if (_isLoading) return false;
    if (_messages.isEmpty) return true;

    final lastMessage = _messages.last;
    return !lastMessage.isUser;
  }

  /// Виджет с кнопками быстрых действий
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'Быстрые действия',
              style: AppTheme.bodySmall.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickActions.map((action) {
              return _buildQuickActionButton(
                title: action['title']!,
                query: action['query']!,
                icon: action['icon']!,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Кнопка быстрого действия
  Widget _buildQuickActionButton({
    required String title,
    required String query,
    required String icon,
  }) {
    IconData iconData;
    switch (icon) {
      case 'location_on':
        iconData = Icons.location_on;
        break;
      case 'photo':
        iconData = Icons.photo;
        break;
      case 'timer':
        iconData = Icons.timer;
        break;
      case 'route':
        iconData = Icons.route;
        break;
      default:
        iconData = Icons.help_outline;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _sendMessage(query),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryLightColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconData, size: 18, color: AppTheme.primaryLightColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryLightColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryLightColor,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Помощник',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Всегда готов помочь',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Список сообщений
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  _messages.length +
                  (_isLoading ? 1 : 0) +
                  (!_isLoading && _shouldShowQuickActions() ? 1 : 0),
              itemBuilder: (context, index) {
                // Показываем сообщения
                if (index < _messages.length) {
                  final message = _messages[index];
                  return Column(
                    children: [
                      _buildMessageBubble(message),
                      if (message.routes != null && message.routes!.isNotEmpty)
                        ...message.routes!.map(
                          (route) => _buildRouteCard(route),
                        ),
                    ],
                  );
                }

                // Показываем кнопки быстрых действий после последнего сообщения
                if (!_isLoading &&
                    _shouldShowQuickActions() &&
                    index == _messages.length) {
                  return _buildQuickActions();
                }

                // Показываем индикатор загрузки
                if (_isLoading &&
                    index ==
                        _messages.length +
                            (_shouldShowQuickActions() ? 1 : 0)) {
                  return _buildLoadingMessage();
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          // Поле ввода
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Напишите сообщение...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryLightColor.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _sendMessage,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryLightColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryLightColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Печатает...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(RouteModel route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 50, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.router.push(
              RouteDescriptionRoute(routeId: route.id, route: route),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Изображение маршрута
                if (route.photoUrls.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      route.photoUrls.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: AppTheme.lightGrey,
                          child: const Icon(
                            Icons.route,
                            color: AppTheme.primaryLightColor,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.route,
                      color: AppTheme.primaryLightColor,
                      size: 32,
                    ),
                  ),
                const SizedBox(width: 12),
                // Информация о маршруте
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: AppTheme.titleSmallBold.copyWith(fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (route.description != null &&
                          route.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          route.description!,
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (route.travelDuration != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${route.travelDuration} мин',
                              style: AppTheme.bodyMini.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
