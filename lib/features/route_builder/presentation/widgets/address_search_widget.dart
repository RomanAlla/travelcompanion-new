import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/presentation/providers/geocoding_service_provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class AddressSearchWidget extends ConsumerStatefulWidget {
  final Function(Point point, String address) onAddressSelected;
  final String? initialAddress;

  const AddressSearchWidget({
    super.key,
    required this.onAddressSelected,
    this.initialAddress,
  });

  @override
  ConsumerState<AddressSearchWidget> createState() =>
      _AddressSearchWidgetState();
}

class _AddressSearchWidgetState extends ConsumerState<AddressSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _searchController.text = widget.initialAddress!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchAddresses(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final geocodingService = ref.read(geocodingServiceProvider);
      final results = await geocodingService.searchAddresses(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
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
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: StatefulBuilder(
            builder: (context, setStateField) {
              return TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Введите адрес или название места',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () {
                            _searchController.clear();
                            setStateField(() {});
                            setState(() {
                              _searchResults = [];
                            });
                          },
                        )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              setStateField(() {});
              // Дебаунс для поиска
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchController.text == value) {
                  _searchAddresses(value);
                }
              });
            },
          );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (_isSearching)
          Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Поиск адресов...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else if (_searchResults.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return InkWell(
                  onTap: () {
                    final point = Point(
                      latitude: result['latitude'] ?? 0.0,
                      longitude: result['longitude'] ?? 0.0,
                    );
                    widget.onAddressSelected(point, result['address'] ?? '');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            result['address'] ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else if (_searchController.text.isNotEmpty && !_isSearching)
          Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Адреса не найдены',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

