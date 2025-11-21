import 'dart:math' as math;
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class RouteValidationError {
  final String message;
  final String? field;

  RouteValidationError(this.message, {this.field});
}

class RouteValidator {
  static List<RouteValidationError> validateRouteForm(RouteForm routeForm) {
    final errors = <RouteValidationError>[];

    if (routeForm.startPoint == null) {
      errors.add(
        RouteValidationError(
          'Необходимо указать начальную точку маршрута',
          field: 'startPoint',
        ),
      );
    }

    if (routeForm.endPoint == null) {
      errors.add(
        RouteValidationError(
          'Необходимо указать конечную точку маршрута',
          field: 'endPoint',
        ),
      );
    }

    if (routeForm.startPoint != null && routeForm.endPoint != null) {
      final distance = _calculateDistance(
        routeForm.startPoint!,
        routeForm.endPoint!,
      );
      if (distance < 10) {
        errors.add(
          RouteValidationError(
            'Начальная и конечная точки слишком близко друг к другу (минимум 10 метров)',
          ),
        );
      }
      if (distance > 50000) {
        errors.add(
          RouteValidationError(
            'Маршрут слишком длинный для пешей прогулки (максимум 50 км)',
          ),
        );
      }
    }

    if (routeForm.name == null || routeForm.name!.trim().isEmpty) {
      errors.add(
        RouteValidationError(
          'Необходимо указать название маршрута',
          field: 'name',
        ),
      );
    } else if (routeForm.name!.trim().length < 3) {
      errors.add(
        RouteValidationError(
          'Название маршрута должно содержать минимум 3 символа',
          field: 'name',
        ),
      );
    } else if (routeForm.name!.trim().length > 100) {
      errors.add(
        RouteValidationError(
          'Название маршрута слишком длинное (максимум 100 символов)',
          field: 'name',
        ),
      );
    }

    if (routeForm.description == null ||
        routeForm.description!.trim().isEmpty) {
      errors.add(
        RouteValidationError(
          'Необходимо указать описание маршрута',
          field: 'description',
        ),
      );
    } else if (routeForm.description!.trim().length < 10) {
      errors.add(
        RouteValidationError(
          'Описание маршрута должно содержать минимум 10 символов',
          field: 'description',
        ),
      );
    } else if (routeForm.description!.trim().length > 2000) {
      errors.add(
        RouteValidationError(
          'Описание маршрута слишком длинное (максимум 2000 символов)',
          field: 'description',
        ),
      );
    }

    // Проверка времени прохождения
    if (routeForm.travelDuration == null) {
      errors.add(
        RouteValidationError(
          'Необходимо указать время прохождения маршрута',
          field: 'travelDuration',
        ),
      );
    } else if (routeForm.travelDuration! < 1) {
      errors.add(
        RouteValidationError(
          'Время прохождения должно быть больше 0 минут',
          field: 'travelDuration',
        ),
      );
    } else if (routeForm.travelDuration! > 1440) {
      errors.add(
        RouteValidationError(
          'Время прохождения слишком большое (максимум 24 часа)',
          field: 'travelDuration',
        ),
      );
    }

    // Проверка количества промежуточных точек
    if (routeForm.wayPoints != null && routeForm.wayPoints!.length > 20) {
      errors.add(
        RouteValidationError(
          'Слишком много промежуточных точек (максимум 20)',
          field: 'wayPoints',
        ),
      );
    }

    // Проверка построения маршрута
    if (routeForm.routes.isEmpty) {
      errors.add(
        RouteValidationError(
          'Не удалось построить маршрут. Проверьте, что точки доступны для пешеходов',
        ),
      );
    }

    return errors;
  }

  static double _calculateDistance(Point point1, Point point2) {
    // Формула гаверсинуса для расчета расстояния между двумя точками
    const double earthRadius = 6371000; // Радиус Земли в метрах
    final lat1Rad = point1.latitude * (math.pi / 180);
    final lat2Rad = point2.latitude * (math.pi / 180);
    final deltaLatRad = (point2.latitude - point1.latitude) * (math.pi / 180);
    final deltaLonRad = (point2.longitude - point1.longitude) * (math.pi / 180);

    final a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLonRad / 2) *
            math.sin(deltaLonRad / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }
}
