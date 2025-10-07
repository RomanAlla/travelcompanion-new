import 'package:flutter/foundation.dart';
import 'package:travelcompanion/features/profile/data/api/countries_api.dart';

class CountryService {
  final CountriesApi _countriesApi;

  CountryService(this._countriesApi);

  Future<List<String>> getCountriesList() async {
    try {
      return await _countriesApi.getCountriesList();
    } catch (e) {
      debugPrint('CountryService error: $e');
      rethrow;
    }
  }
}
