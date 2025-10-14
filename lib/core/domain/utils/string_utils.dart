class StringUtils {
  static String pluralizeRoute(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) {
      return '$count маршрут';
    } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      return '$count маршрута';
    } else {
      return '$count маршрутов';
    }
  }

  static String pluralizeReviews(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) {
      return '$count отзыв';
    } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      return '$count отзыва';
    } else {
      return '$count отзывов';
    }
  }
}
