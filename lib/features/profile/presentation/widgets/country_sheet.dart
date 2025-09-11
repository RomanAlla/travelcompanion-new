import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/core/widgets/search_bar_widget.dart';
import 'package:travelcompanion/features/profile/data/api/countries_api.dart';

class CountrySheet extends StatefulWidget {
  final Function(String)? onSelectedCountry;
  const CountrySheet({super.key, this.onSelectedCountry});

  @override
  State<CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<CountrySheet> {
  List<String> countries = [];
  List<String> filteredCountriesList = [];
  String searchQuery = '';
  final _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    getCountriesList();
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
      filteredCountriesList = countries
          .where((country) => country.toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  void _selectCountry(String country) {
    widget.onSelectedCountry?.call(country);
    context.router.pop();
  }

  Future<void> getCountriesList() async {
    try {
      final countriesList = await CountriesApi().getCountriesList();
      setState(() {
        countries = countriesList;
        filteredCountriesList = countries;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Выберите страну', style: AppTheme.titleSmall),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SearchBarWidget(
                    controller: _searchController,
                    onChanged: widget.onSelectedCountry,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Отменить',
                    style: AppTheme.bodyMediumBold.copyWith(
                      color: AppTheme.primaryLightColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemBuilder: (context, index) {
                        final country = filteredCountriesList[index];
                        return ListTile(
                          onTap: () => _selectCountry(country),
                          title: Text(country, style: AppTheme.bodyMedium),
                        );
                      },
                      itemCount: filteredCountriesList.length,
                      separatorBuilder: (context, index) {
                        return Divider(thickness: 0.1);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
