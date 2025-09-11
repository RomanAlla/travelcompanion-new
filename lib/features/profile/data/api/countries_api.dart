import 'package:dio/dio.dart';

class CountriesApi {
  final dio = Dio();
  Future<List<String>> getCountriesList() async {
    try {
      final response = await dio.get(
        'https://countriesnow.space/api/v0.1/countries',
      );
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['error'] == false) {
          final countriesData = responseData['data'] as List<dynamic>;
          final countriesList = countriesData
              .map<String>((country) => country['country'] as String)
              .toList();
          return countriesList;
        } else {
          throw Exception('Ошибка API: ${responseData['msg']}');
        }
      } else {
        throw Exception('Ошибка HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при получении списка стран: $e');
    }
  }
}
