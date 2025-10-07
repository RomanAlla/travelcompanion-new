import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/presentation/widgets/search_bar_widget.dart';
import 'package:travelcompanion/features/profile/presentation/providers/countries_list_provider.dart';

class CountrySheet extends ConsumerWidget {
  final Function(String)? onSelectedCountry;
  const CountrySheet({super.key, this.onSelectedCountry});

  void _selectCountry(String country, BuildContext context) {
    onSelectedCountry?.call(country);
    context.router.pop();
  }

  List<String> filterCountries(List<String> countries, String query) {
    final filteredCountries = countries
        .where(
          (countries) => countries.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return filteredCountries;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(countriesListProvider);
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
                    controller: ref.watch(searchControllerProvider),
                    onChanged: (query) =>
                        ref.watch(searchQueryProvider.notifier).state = query,
                  ),
                ),
                TextButton(
                  onPressed: () => context.router.pop(context),
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
              child: countriesAsync.when(
                data: (countryList) {
                  final query = ref.watch(searchQueryProvider);
                  final filteredList = filterCountries(countryList, query);
                  return ListView.separated(
                    itemBuilder: (context, index) {
                      final country = filteredList[index];
                      return ListTile(
                        onTap: () => _selectCountry(country, context),
                        title: Text(country, style: AppTheme.bodyMedium),
                      );
                    },
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) {
                      return Divider(thickness: 0.1);
                    },
                  );
                },
                error: (e, _) => ErrorWidget(e),
                loading: () => Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
