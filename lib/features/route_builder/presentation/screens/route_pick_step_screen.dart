import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/presentation/providers/address_provider.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/map/domain/enums/route_pick_state.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_state_notifier_provider.dart';
import 'package:travelcompanion/features/map/presentation/providers/yandex_map_service_provider.dart';
import 'package:travelcompanion/features/map/presentation/widgets/yandex_map_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/page_controller_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/modal_point_select_container_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/address_search_widget.dart';
import 'package:travelcompanion/core/presentation/providers/geocoding_service_provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'dart:async';

class RoutePickStepScreen extends ConsumerStatefulWidget {
  const RoutePickStepScreen({super.key});

  @override
  ConsumerState<RoutePickStepScreen> createState() =>
      _RoutePickStepWidgetState();
}

class _RoutePickStepWidgetState extends ConsumerState<RoutePickStepScreen> {
  bool isExpanded = false;
  bool isHidden = false;
  String? pointType;

  void _expandedToggle(String? newPointType) {
    setState(() {
      isExpanded = !isExpanded;
      if (!isExpanded) {
        isHidden = false;
      }
      pointType = newPointType;
    });
  }

  void _hidePanel() {
    setState(() {
      isExpanded = false;
      isHidden = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double collapsedHeight = 200;
    double expandedHeight = MediaQuery.of(context).size.height * 0.7;
    final pointState = ref.watch(routeBuilderNotifierProvider);

    return Scaffold(
      body: Stack(
        children: [
          YandexMapWidget(mode: MapMode.pickMainPoints),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 8.0,
                bottom: 8.0,
              ),
              child: Column(
                children: [
                  // Поиск адреса - всегда видимый
                  _AddressSearchFieldWidget(pointState: pointState, ref: ref),
                  const SizedBox(height: 8),
                  // Информационное сообщение
                  Builder(
                    builder: (context) {
                      final currentPointState = ref.watch(
                        routeBuilderNotifierProvider,
                      );
                      final mapState = ref.watch(mapStateNotifierProvider);
                      final currentError = mapState.error;
                      final isLoading = mapState.isLoading;

                      if (isLoading) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text('Построение маршрута...'),
                            ],
                          ),
                        );
                      }

                      final currentHasRoute =
                          currentPointState.routes.isNotEmpty;
                      final helperText =
                          (currentError != null && !currentHasRoute)
                          ? currentError
                          : switch (currentPointState.status) {
                              PointPickState.none =>
                                'Поставьте точку начала маршрута',
                              PointPickState.startPicked =>
                                'Поставьте точку конца маршрута',
                              PointPickState.bothPicked => 'Маршрут готов',
                            };

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                helperText,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Нижняя панель с точками маршрута
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: isHidden ? -expandedHeight : 0,
            right: 0,
            left: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle для перетаскивания
                  GestureDetector(
                    onTap: () {
                      if (isExpanded) {
                        _expandedToggle(null);
                      } else {
                        _hidePanel();
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: SizedBox(
                      height: isExpanded
                          ? expandedHeight - 20
                          : collapsedHeight,
                      child: SingleChildScrollView(
                        physics: isExpanded
                            ? const AlwaysScrollableScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            children: [
                              // Контент панели
                              if (isExpanded) ...[
                                // Режим поиска
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _expandedToggle(null),
                                      icon: const Icon(Icons.arrow_back),
                                      iconSize: 24,
                                    ),
                                    Expanded(
                                      child: Text(
                                        pointType == 'start'
                                            ? 'Поиск начальной точки'
                                            : 'Поиск конечной точки',
                                        style: AppTheme.titleMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 48),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                AddressSearchWidget(
                                  initialAddress: pointType == 'start'
                                      ? (pointState.startPoint != null
                                            ? '${pointState.startPoint?.latitude.toStringAsFixed(4)}, ${pointState.startPoint?.longitude.toStringAsFixed(4)}'
                                            : null)
                                      : (pointState.endPoint != null
                                            ? '${pointState.endPoint?.latitude.toStringAsFixed(4)}, ${pointState.endPoint?.longitude.toStringAsFixed(4)}'
                                            : null),
                                  onAddressSelected: (point, address) {
                                    if (pointType == 'start') {
                                      ref
                                          .read(
                                            routeBuilderNotifierProvider
                                                .notifier,
                                          )
                                          .addStartPoint(point, ref);
                                    } else {
                                      ref
                                          .read(
                                            routeBuilderNotifierProvider
                                                .notifier,
                                          )
                                          .addEndPoint(point, ref);
                                    }
                                    _expandedToggle(null);
                                  },
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                ),
                              ] else ...[
                                // Обычный режим - карточки точек
                                Row(
                                  children: [
                                    Expanded(
                                      child: pointState.startPoint != null
                                          ? FutureBuilder<String>(
                                              future: ref.read(
                                                addressProvider(
                                                  pointState.startPoint!,
                                                ).future,
                                              ),
                                              builder: (context, snapshot) {
                                                final address =
                                                    snapshot.data ??
                                                    '${pointState.startPoint?.latitude.toStringAsFixed(4)}, ${pointState.startPoint?.longitude.toStringAsFixed(4)}';
                                                return ModalPointSelectContainerWidget(
                                                  icon: Icons.location_on,
                                                  title: address,
                                                  onTap: () =>
                                                      _expandedToggle('start'),
                                                  isActive:
                                                      pointState.status !=
                                                      PointPickState.none,
                                                );
                                              },
                                            )
                                          : ModalPointSelectContainerWidget(
                                              icon: Icons.location_on,
                                              title: 'Начальная точка',
                                              onTap: () =>
                                                  _expandedToggle('start'),
                                              isActive: false,
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: pointState.endPoint != null
                                          ? FutureBuilder<String>(
                                              future: ref.read(
                                                addressProvider(
                                                  pointState.endPoint!,
                                                ).future,
                                              ),
                                              builder: (context, snapshot) {
                                                final address =
                                                    snapshot.data ??
                                                    '${pointState.endPoint?.latitude.toStringAsFixed(4)}, ${pointState.endPoint?.longitude.toStringAsFixed(4)}';
                                                return ModalPointSelectContainerWidget(
                                                  icon: Icons.flag,
                                                  title: address,
                                                  onTap: () =>
                                                      _expandedToggle('end'),
                                                  isActive:
                                                      pointState.status ==
                                                      PointPickState.bothPicked,
                                                );
                                              },
                                            )
                                          : ModalPointSelectContainerWidget(
                                              icon: Icons.flag,
                                              title: 'Конечная точка',
                                              onTap: () =>
                                                  _expandedToggle('end'),
                                              isActive: false,
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                pointState.status == PointPickState.bothPicked
                                    ? Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      routeBuilderNotifierProvider
                                                          .notifier,
                                                    )
                                                    .clearAll(ref);
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              label: const Text(
                                                'Очистить',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor:
                                                    AppTheme.lightBlue,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: ContinueActionButtonWidget(
                                              label: 'Готово',
                                              onPressed: () async {
                                                // Проверяем, что маршрут построен
                                                final routeInfo = ref.read(
                                                  routeBuilderNotifierProvider,
                                                );
                                                if (routeInfo.routes.isEmpty) {
                                                  // Пытаемся построить маршрут
                                                  await ref
                                                      .read(
                                                        yandexMapServiceProvider,
                                                      )
                                                      .buildPedestrianRoute(
                                                        ref,
                                                      );

                                                  // Проверяем еще раз
                                                  final updatedRouteInfo = ref.read(
                                                    routeBuilderNotifierProvider,
                                                  );
                                                  if (updatedRouteInfo
                                                      .routes
                                                      .isEmpty) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Не удалось построить маршрут. Проверьте точки и попробуйте снова.',
                                                          ),
                                                          backgroundColor:
                                                              Colors.red,
                                                          duration: Duration(
                                                            seconds: 3,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return;
                                                  }
                                                }

                                                ref
                                                    .read(
                                                      pageControllerProvider,
                                                    )
                                                    .nextPage(
                                                      duration: const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      curve: Curves.ease,
                                                    );
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: BackActionButtonWidget(
                                              onPressed: () =>
                                                  context.router.pop(),
                                              label: 'Выйти',
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                onPressed: _hidePanel,
                                                icon: const Icon(Icons.map),
                                                label: Text(
                                                  'Выбрать на карте',
                                                  style: AppTheme.bodySmallBold
                                                      .copyWith(
                                                        color: AppTheme
                                                            .primaryLightColor,
                                                      ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isHidden)
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 4,
                onPressed: () {
                  setState(() {
                    isHidden = false;
                    isExpanded = false;
                  });
                },
                child: const Icon(Icons.keyboard_arrow_up),
              ),
            ),
        ],
      ),
    );
  }
}

// Виджет поиска адреса с прозрачным списком результатов
class _AddressSearchFieldWidget extends ConsumerStatefulWidget {
  final RouteForm pointState;
  final WidgetRef ref;

  const _AddressSearchFieldWidget({
    required this.pointState,
    required this.ref,
  });

  @override
  ConsumerState<_AddressSearchFieldWidget> createState() =>
      _AddressSearchFieldWidgetState();
}

class _AddressSearchFieldWidgetState
    extends ConsumerState<_AddressSearchFieldWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showResults =
            _focusNode.hasFocus && _searchController.text.trim().length >= 2;
      });
    });
  }

  Timer? _debounceTimer;

  Future<void> _searchAddresses(String query) async {
    // Отменяем предыдущий таймер
    _debounceTimer?.cancel();

    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty || trimmedQuery.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _showResults = false;
      });
      return;
    }

    // Устанавливаем состояние загрузки сразу
    setState(() {
      _isSearching = true;
      _showResults = true;
    });

    // Дебаунс 300мс для более быстрого отклика
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        debugPrint('Searching for: $trimmedQuery');
        final geocodingService = ref.read(geocodingServiceProvider);
        final results = await geocodingService.searchAddresses(trimmedQuery);
        debugPrint('Search results: ${results.length} items');

        if (mounted && _searchController.text.trim() == trimmedQuery) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
            _showResults = results.isNotEmpty || trimmedQuery.length >= 2;
          });
        }
      } catch (e, stackTrace) {
        debugPrint('Error in search: $e');
        debugPrint('Stack trace: $stackTrace');
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onAddressSelected(Point point, String address) {
    _searchController.clear();
    _focusNode.unfocus();
    setState(() {
      _showResults = false;
      _searchResults = [];
    });

    // Определяем, какую точку установить
    if (widget.pointState.startPoint == null) {
      widget.ref
          .read(routeBuilderNotifierProvider.notifier)
          .addStartPoint(point, widget.ref);
    } else if (widget.pointState.endPoint == null) {
      widget.ref
          .read(routeBuilderNotifierProvider.notifier)
          .addEndPoint(point, widget.ref);
    } else {
      // Если обе точки есть, спрашиваем какую заменить
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Выберите точку'),
          content: const Text('Какую точку заменить?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.ref
                    .read(routeBuilderNotifierProvider.notifier)
                    .addStartPoint(point, widget.ref);
              },
              child: const Text('Начальную'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.ref
                    .read(routeBuilderNotifierProvider.notifier)
                    .addEndPoint(point, widget.ref);
              },
              child: const Text('Конечную'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Поиск адреса...',
              prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                          _showResults = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              final shouldShow =
                  _focusNode.hasFocus && value.trim().length >= 2;
              setState(() {
                _showResults = shouldShow;
              });
              if (shouldShow) {
                _searchAddresses(value);
              } else {
                setState(() {
                  _searchResults = [];
                  _isSearching = false;
                });
              }
            },
          ),
        ),
        // Прозрачный список результатов
        if (_showResults || _isSearching)
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isSearching
                ? Container(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                : _searchResults.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Адреса не найдены',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _searchResults.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[200],
                      indent: 56,
                    ),
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      final address = result['address'] ?? '';
                      final description = result['description'] ?? '';
                      final kind = result['kind'] ?? '';

                      // Определяем иконку по типу места
                      IconData iconData;
                      Color iconColor;
                      if (kind == 'house') {
                        iconData = Icons.home;
                        iconColor = theme.colorScheme.primary;
                      } else if (kind == 'street') {
                        iconData = Icons.signpost;
                        iconColor = Colors.blue;
                      } else if (kind == 'locality' || kind == 'district') {
                        iconData = Icons.location_city;
                        iconColor = Colors.orange;
                      } else {
                        iconData = Icons.location_on;
                        iconColor = theme.colorScheme.primary;
                      }

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final point = Point(
                              latitude: result['latitude'] ?? 0.0,
                              longitude: result['longitude'] ?? 0.0,
                            );
                            _onAddressSelected(point, address);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: iconColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    iconData,
                                    color: iconColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        address,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (description.isNotEmpty &&
                                          description != address)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            description,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
