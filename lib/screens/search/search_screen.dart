import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_state.dart'
    show AppState, SearchResult, SearchResultType;

/// Search screen for finding clients, sites, and equipment
/// Implements FR-012
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];
  bool _isSearching = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search clients, sites, equipment...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _query = '';
                      _results = [];
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        onChanged: (value) {
          setState(() => _query = value);
          if (value.length >= 2) {
            _performSearch(value);
          } else {
            setState(() => _results = []);
          }
        },
      ),
    );
  }

  Widget _buildResultsList() {
    if (_query.isEmpty) {
      return _buildEmptyState();
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        return _buildResultTile(_results[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Search for anything',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Clients, sites, equipment, or serial numbers',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or check spelling',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(SearchResult result) {
    IconData icon;
    Color iconColor;

    switch (result.type) {
      case SearchResultType.client:
        icon = Icons.business;
        iconColor = Colors.purple;
        break;
      case SearchResultType.mainSite:
        icon = Icons.location_city;
        iconColor = Colors.blue;
        break;
      case SearchResultType.subSite:
        icon = Icons.folder;
        iconColor = Colors.orange;
        break;
      case SearchResultType.equipment:
        icon = Icons.precision_manufacturing;
        iconColor = Colors.green;
        break;
    }

    return ListTile(
      leading: Icon(icon, size: 40, color: iconColor),
      title: Text(result.title),
      subtitle: Text(result.subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _navigateToResult(result),
    );
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);

    try {
      final appState = context.read<AppState>();
      final results = await appState.search(query);

      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search error: $e')));
    }
  }

  void _navigateToResult(SearchResult result) {
    switch (result.type) {
      case SearchResultType.client:
        context.push('/client/${result.id}');
        break;
      case SearchResultType.mainSite:
        context.push('/site/${result.id}');
        break;
      case SearchResultType.subSite:
        context.push('/subsite/${result.id}');
        break;
      case SearchResultType.equipment:
        context.push('/equipment/${result.id}');
        break;
    }
  }
}
