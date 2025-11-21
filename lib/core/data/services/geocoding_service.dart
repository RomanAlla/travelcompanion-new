import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:yandex_mapkit/yandex_mapkit.dart';

class GeocodingService {
  final Dio _dio = Dio();
  final Map<String, String> _addressCache = {};

  Future<String> getAddressFromCoordinates(Point point) async {
    final cacheKey = '${point.latitude}_${point.longitude}';

    if (_addressCache.containsKey(cacheKey)) {
      return _addressCache[cacheKey]!;
    }

    try {
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          point.latitude,
          point.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final addressParts = <String>[];

          if (placemark.street != null && placemark.street!.isNotEmpty) {
            addressParts.add(placemark.street!);
          }
          if (placemark.subThoroughfare != null &&
              placemark.subThoroughfare!.isNotEmpty) {
            addressParts.add(placemark.subThoroughfare!);
          }
          if (placemark.locality != null && placemark.locality!.isNotEmpty) {
            addressParts.add(placemark.locality!);
          }
          if (placemark.country != null && placemark.country!.isNotEmpty) {
            addressParts.add(placemark.country!);
          }

          if (addressParts.isNotEmpty) {
            final address = addressParts.join(', ');
            _addressCache[cacheKey] = address;
            return address;
          }
        }
      } catch (e) {
        debugPrint('Error using geocoding package: $e');
      }

      final apiKey = dotenv.env['YANDEX_GEOCODER_API_KEY'] ?? '';

      if (apiKey.isNotEmpty) {
        try {
          final response = await _dio.get(
            'https://geocode-maps.yandex.ru/1.x/',
            queryParameters: {
              'apikey': apiKey,
              'geocode': '${point.longitude},${point.latitude}',
              'format': 'json',
              'results': 1,
            },
            options: Options(validateStatus: (status) => status! < 500),
          );

          if (response.statusCode == 200 && response.data != null) {
            final data = response.data;
            final featureMembers =
                data['response']?['GeoObjectCollection']?['featureMember'];

            if (featureMembers != null && featureMembers.isNotEmpty) {
              final geoObject = featureMembers[0]['GeoObject'];
              final address =
                  geoObject['metaDataProperty']?['GeocoderMetaData']?['text'];

              if (address != null && address is String && address.isNotEmpty) {
                _addressCache[cacheKey] = address;
                return address;
              }
            }
          } else if (response.statusCode == 403) {
            debugPrint(
              'Yandex Geocoder API: 403 Forbidden. Check API key and permissions.',
            );
          }
        } catch (e) {
          debugPrint('Error using Yandex Geocoder API: $e');
        }
      }
    } catch (e) {
      debugPrint('Error geocoding: $e');
    }

    final fallback =
        '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
    _addressCache[cacheKey] = fallback;
    return fallback;
  }

  Future<List<Map<String, dynamic>>> searchAddresses(String query) async {
    if (query.trim().isEmpty || query.trim().length < 2) {
      return [];
    }

    try {
      final apiKey = dotenv.env['YANDEX_GEOCODER_API_KEY'] ?? '';

      if (apiKey.isNotEmpty) {
        try {
          final response = await _dio.get(
            'https://geocode-maps.yandex.ru/1.x/',
            queryParameters: {
              'apikey': apiKey,
              'geocode': query,
              'format': 'json',
              'results': 15,
            },
            options: Options(validateStatus: (status) => status! < 500),
          );

          debugPrint(
            'Yandex Geocoder API request: query=$query, status=${response.statusCode}',
          );

          if (response.statusCode == 400) {
            debugPrint('Got 400 error, retrying without results parameter');
            try {
              final retryResponse = await _dio.get(
                'https://geocode-maps.yandex.ru/1.x/',
                queryParameters: {
                  'apikey': apiKey,
                  'geocode': query,
                  'format': 'json',
                },
                options: Options(validateStatus: (status) => status! < 500),
              );

              debugPrint('Retry response status: ${retryResponse.statusCode}');

              if (retryResponse.statusCode == 200 &&
                  retryResponse.data != null) {
                final data = retryResponse.data;
                final featureMembers =
                    data['response']?['GeoObjectCollection']?['featureMember'];

                if (featureMembers != null && featureMembers.isNotEmpty) {
                  debugPrint(
                    'Retry successful, found ${featureMembers.length} results',
                  );
                  return _parseYandexResults(featureMembers, query);
                }
              }
            } catch (retryError) {
              debugPrint('Retry also failed: $retryError');
            }
          } else if (response.statusCode == 200 && response.data != null) {
            final data = response.data;
            debugPrint('Yandex API response keys: ${data.keys}');

            final featureMembers =
                data['response']?['GeoObjectCollection']?['featureMember'];

            debugPrint(
              'Yandex Geocoder API: found ${featureMembers?.length ?? 0} results',
            );

            if (featureMembers == null) {
              debugPrint(
                'featureMembers is null, response structure: ${data['response']?.keys}',
              );
            }

            if (featureMembers != null && featureMembers.isNotEmpty) {
              return _parseYandexResults(featureMembers, query);
            }
          }
        } catch (e, stackTrace) {
          debugPrint('Error using Yandex Geocoder API for search: $e');
          debugPrint('Stack trace: $stackTrace');
        }
      } else {
        debugPrint('Yandex Geocoder API key is empty, using fallback');
      }

      try {
        debugPrint('Trying geocoding package for query: $query');
        final locations = await geocoding.locationFromAddress(query);
        debugPrint('Geocoding package found ${locations.length} results');

        return locations.map((location) {
          return {
            'latitude': location.latitude,
            'longitude': location.longitude,
            'address': query,
            'description': '',
            'kind': '',
          };
        }).toList();
      } catch (e) {
        debugPrint('Error using geocoding package for search: $e');
      }
    } catch (e) {
      debugPrint('Error searching addresses: $e');
    }

    return [];
  }

  List<Map<String, dynamic>> _parseYandexResults(
    List<dynamic> featureMembers,
    String query,
  ) {
    return featureMembers.map<Map<String, dynamic>>((member) {
      final geoObject = member['GeoObject'];
      final point = geoObject['Point']?['pos']?.split(' ');
      final geocoderMetaData =
          geoObject['metaDataProperty']?['GeocoderMetaData'];
      final address = geocoderMetaData?['text'] ?? query;
      final kind = geocoderMetaData?['kind'] ?? '';
      final addressDetails =
          geocoderMetaData?['Address']?['Components'] as List?;

      String? city;
      String? street;
      String? house;

      if (addressDetails != null) {
        for (var component in addressDetails) {
          final componentKind = component['kind'];
          if (componentKind == 'locality' || componentKind == 'district') {
            city = component['name'];
          } else if (componentKind == 'street') {
            street = component['name'];
          } else if (componentKind == 'house') {
            house = component['name'];
          }
        }
      }

      String description = '';
      if (city != null && city.isNotEmpty) {
        description = city;
        if (street != null && street.isNotEmpty) {
          description += ', $street';
        }
      } else if (street != null && street.isNotEmpty) {
        description = street;
      }

      if (point != null && point.length == 2) {
        return {
          'longitude': double.tryParse(point[0]) ?? 0.0,
          'latitude': double.tryParse(point[1]) ?? 0.0,
          'address': address,
          'description': description,
          'kind': kind,
          'city': city ?? '',
          'street': street ?? '',
          'house': house ?? '',
        };
      }
      return {
        'longitude': 0.0,
        'latitude': 0.0,
        'address': address,
        'description': description,
        'kind': kind,
      };
    }).toList();
  }

  void clearCache() {
    _addressCache.clear();
  }
}
