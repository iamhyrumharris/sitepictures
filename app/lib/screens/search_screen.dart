import 'package:flutter/material.dart';
import 'dart:async';
import '../models/photo.dart';
import '../models/equipment.dart';
import '../models/client.dart';
import '../models/site.dart';
import '../services/search_service.dart';
import '../services/storage_service.dart';

// T053: Search screen with filters
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _searchService = SearchService();
  final StorageService _storageService = StorageService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  String _searchQuery = '';

  // Filter options
  String _selectedType = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  double? _searchRadius;
  double? _searchLat;
  double? _searchLng;

  final List<String> _searchTypes = ['all', 'photos', 'equipment', 'sites', 'clients'];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _searchQuery = query;
    });

    // Debounce search to avoid excessive queries
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;

    final startTime = DateTime.now();

    setState(() {
      _isSearching = true;
    });

    try {
      List<dynamic> results = [];

      // Search based on selected type
      switch (_selectedType) {
        case 'photos':
          results = await _searchService.searchPhotos(
            query: _searchQuery,
            startDate: _startDate,
            endDate: _endDate,
            nearLatitude: _searchLat,
            nearLongitude: _searchLng,
            radiusMeters: _searchRadius,
          );
          break;

        case 'equipment':
          results = await _searchService.searchEquipment(
            query: _searchQuery,
          );
          break;

        case 'sites':
          results = await _searchService.searchSites(
            query: _searchQuery,
          );
          break;

        case 'clients':
          results = await _searchService.searchClients(
            query: _searchQuery,
          );
          break;

        default: // 'all'
          final photos = await _searchService.searchPhotos(
            query: _searchQuery,
            startDate: _startDate,
            endDate: _endDate,
            nearLatitude: _searchLat,
            nearLongitude: _searchLng,
            radiusMeters: _searchRadius,
          );
          final equipment = await _searchService.searchEquipment(query: _searchQuery);
          final sites = await _searchService.searchSites(query: _searchQuery);
          final clients = await _searchService.searchClients(query: _searchQuery);

          results = [...photos, ...equipment, ...sites, ...clients];
      }

      // Check search performance (<1s constitutional requirement)
      final searchTime = DateTime.now().difference(startTime);
      if (searchTime.inMilliseconds > 1000) {
        debugPrint('Warning: Search took ${searchTime.inMilliseconds}ms');
      }

      setState(() {
        _searchResults = results;
      });

    } catch (e) {
      _showError('Search failed: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Widget _buildSearchFilters() {
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Type filter
          FilterChip(
            label: Text(_selectedType == 'all' ? 'All Types' : _selectedType.capitalize()),
            selected: true,
            onSelected: (_) => _showTypeFilter(),
          ),
          const SizedBox(width: 8),

          // Date range filter
          FilterChip(
            label: Text(_startDate != null || _endDate != null
                ? 'Date Range Set'
                : 'Date Range'),
            selected: _startDate != null || _endDate != null,
            onSelected: (_) => _showDateRangeFilter(),
          ),
          const SizedBox(width: 8),

          // Location filter
          FilterChip(
            label: Text(_searchLat != null ? 'Near Location' : 'Location'),
            selected: _searchLat != null,
            onSelected: (_) => _showLocationFilter(),
          ),
          const SizedBox(width: 8),

          // Clear filters
          if (_hasActiveFilters())
            ActionChip(
              label: const Text('Clear Filters'),
              onPressed: _clearFilters,
            ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedType != 'all' ||
           _startDate != null ||
           _endDate != null ||
           _searchLat != null;
  }

  void _clearFilters() {
    setState(() {
      _selectedType = 'all';
      _startDate = null;
      _endDate = null;
      _searchLat = null;
      _searchLng = null;
      _searchRadius = null;
    });
    _performSearch();
  }

  void _showTypeFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._searchTypes.map((type) => RadioListTile<String>(
              title: Text(type.capitalize()),
              value: type,
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
                Navigator.pop(context);
                _performSearch();
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showDateRangeFilter() async {
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
      _performSearch();
    }
  }

  void _showLocationFilter() {
    // TODO: Implement location picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location filter coming soon')),
    );
  }

  Widget _buildSearchResult(dynamic result) {
    if (result is Photo) {
      return ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.photo),
        ),
        title: Text(result.notes ?? 'Photo ${result.id.substring(0, 8)}'),
        subtitle: Text(_formatDateTime(result.capturedAt)),
        trailing: Icon(
          result.isSynced ? Icons.cloud_done : Icons.cloud_upload_outlined,
          size: 20,
          color: result.isSynced ? Colors.green : Colors.orange,
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/photo-viewer',
            arguments: result,
          );
        },
      );

    } else if (result is Equipment) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(Icons.settings_input_component, color: Colors.blue),
        ),
        title: Text(result.name),
        subtitle: Text(result.equipmentType ?? 'Equipment'),
        trailing: FutureBuilder<int>(
          future: _storageService.getPhotoCountForEquipment(result.id),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data! > 0) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${snapshot.data}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/equipment-detail',
            arguments: result,
          );
        },
      );

    } else if (result is Site) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: const Icon(Icons.location_city, color: Colors.green),
        ),
        title: Text(result.name),
        subtitle: Text(result.address ?? 'Site'),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/navigation',
            arguments: {'site': result},
          );
        },
      );

    } else if (result is Client) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.1),
          child: const Icon(Icons.business, color: Colors.purple),
        ),
        title: Text(result.name),
        subtitle: Text(result.description ?? 'Client'),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/navigation',
            arguments: {'client': result},
          );
        },
      );

    } else {
      return const SizedBox.shrink();
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search photos, equipment, sites...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          if (_searchQuery.isNotEmpty)
            _buildSearchFilters(),
          const Divider(height: 1),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchQuery.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Start typing to search',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Search across photos, equipment, sites, and clients',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found for "$_searchQuery"',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (_hasActiveFilters()) ...[
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _clearFilters,
                                    child: const Text('Clear filters and try again'),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return _buildSearchResult(_searchResults[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}