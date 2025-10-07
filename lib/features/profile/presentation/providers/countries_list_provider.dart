import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/profile/data/api/countries_api.dart';
import 'package:travelcompanion/features/profile/data/services/country_service.dart';

final countryServiceProvider = Provider<CountryService>((ref) {
  return CountryService(CountriesApi());
});
final countriesListProvider = FutureProvider<List<String>>((ref) {
  return ref.read(countryServiceProvider).getCountriesList();
});

final searchControllerProvider = Provider<TextEditingController>((ref) {
  final text = TextEditingController();
  ref.onDispose(() => text.dispose());
  return text;
});

final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});
