import 'package:flutter/material.dart';
import '../models/company.dart';
import '../models/client.dart';
import '../models/site.dart';
import '../models/equipment.dart';
import '../services/navigation_service.dart';
import '../services/storage_service.dart';

// T051: Navigation screen with breadcrumbs
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final NavigationService _navigationService = NavigationService();
  final StorageService _storageService = StorageService();

  Company? _currentCompany;
  Client? _currentClient;
  Site? _currentSite;
  Equipment? _currentEquipment;

  List<dynamic> _currentItems = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load company and top-level clients
      final company = await _storageService.getCurrentCompany();
      if (company != null) {
        _currentCompany = company;
        final clients = await _storageService.getClientsForCompany(company.id);
        _currentItems = clients;
      }
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToClient(Client client) async {
    final startTime = DateTime.now();

    setState(() {
      _isLoading = true;
      _currentClient = client;
    });

    try {
      final sites = await _storageService.getSitesForClient(client.id);
      _currentItems = sites;
      _currentSite = null;
      _currentEquipment = null;

      // Ensure navigation is <500ms (constitutional requirement)
      final duration = DateTime.now().difference(startTime);
      if (duration.inMilliseconds > 500) {
        debugPrint('Warning: Navigation took ${duration.inMilliseconds}ms');
      }
    } catch (e) {
      _showError('Failed to load sites: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToSite(Site site) async {
    final startTime = DateTime.now();

    setState(() {
      _isLoading = true;
      _currentSite = site;
    });

    try {
      // Load sub-sites and equipment
      final subSites = await _storageService.getSubSites(site.id);
      final equipment = await _storageService.getEquipmentForSite(site.id);

      _currentItems = [...subSites, ...equipment];
      _currentEquipment = null;

      // Check navigation speed
      final duration = DateTime.now().difference(startTime);
      if (duration.inMilliseconds > 500) {
        debugPrint('Warning: Navigation took ${duration.inMilliseconds}ms');
      }
    } catch (e) {
      _showError('Failed to load site contents: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEquipment(Equipment equipment) async {
    setState(() {
      _currentEquipment = equipment;
    });

    // Navigate to equipment detail screen
    Navigator.pushNamed(
      context,
      '/equipment-detail',
      arguments: equipment,
    );
  }

  void _navigateUp() {
    setState(() {
      _isLoading = true;
    });

    if (_currentEquipment != null) {
      _currentEquipment = null;
      _navigateToSite(_currentSite!);
    } else if (_currentSite != null) {
      if (_currentSite!.parentSiteId != null) {
        // Navigate to parent site
        _storageService.getSiteById(_currentSite!.parentSiteId!).then((parentSite) {
          if (parentSite != null) {
            _navigateToSite(parentSite);
          }
        });
      } else {
        // Navigate back to client
        _currentSite = null;
        _navigateToClient(_currentClient!);
      }
    } else if (_currentClient != null) {
      // Navigate back to company level
      _currentClient = null;
      _loadInitialData();
    }
  }

  List<String> _getBreadcrumbs() {
    final breadcrumbs = <String>[];

    if (_currentCompany != null) {
      breadcrumbs.add(_currentCompany!.name);
    }

    if (_currentClient != null) {
      breadcrumbs.add(_currentClient!.name);
    }

    if (_currentSite != null) {
      breadcrumbs.add(_currentSite!.name);
    }

    if (_currentEquipment != null) {
      breadcrumbs.add(_currentEquipment!.name);
    }

    return breadcrumbs;
  }

  Widget _buildBreadcrumbs() {
    final breadcrumbs = _getBreadcrumbs();

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: breadcrumbs.length,
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        ),
        itemBuilder: (context, index) {
          final isLast = index == breadcrumbs.length - 1;
          return GestureDetector(
            onTap: isLast ? null : () => _navigateToBreadcrumb(index),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                breadcrumbs[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                  color: isLast ? Theme.of(context).primaryColor : Colors.grey[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToBreadcrumb(int index) {
    if (index == 0 && _currentCompany != null) {
      _currentClient = null;
      _currentSite = null;
      _currentEquipment = null;
      _loadInitialData();
    } else if (index == 1 && _currentClient != null) {
      _currentSite = null;
      _currentEquipment = null;
      _navigateToClient(_currentClient!);
    } else if (index == 2 && _currentSite != null) {
      _currentEquipment = null;
      _navigateToSite(_currentSite!);
    }
  }

  Widget _buildItemTile(dynamic item) {
    IconData icon;
    String subtitle = '';
    VoidCallback onTap;

    if (item is Client) {
      icon = Icons.business;
      subtitle = '${item.sites?.length ?? 0} sites';
      onTap = () => _navigateToClient(item);
    } else if (item is Site) {
      icon = Icons.location_city;
      subtitle = item.address ?? 'Site';
      if (item.parentSiteId != null) {
        icon = Icons.subdirectory_arrow_right;
        subtitle = 'Sub-site';
      }
      onTap = () => _navigateToSite(item);
    } else if (item is Equipment) {
      icon = Icons.settings_input_component;
      subtitle = item.equipmentType ?? 'Equipment';
      onTap = () => _navigateToEquipment(item);
    } else {
      return const SizedBox.shrink();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty &&
        !item.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item is Equipment)
              FutureBuilder<int>(
                future: _storageService.getPhotoCountForEquipment(item.id),
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
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
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
        title: const Text('Navigate'),
        leading: _currentClient != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateUp,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/camera',
                arguments: _currentEquipment,
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: _buildBreadcrumbs(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          if (_currentItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search in current level...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No items found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_currentClient != null || _currentSite != null)
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Add new item
                                  Navigator.pushNamed(
                                    context,
                                    _currentSite != null ? '/add-equipment' : '/add-site',
                                    arguments: _currentSite ?? _currentClient,
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: Text(_currentSite != null ? 'Add Equipment' : 'Add Site'),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          if (_currentSite != null) {
                            await _navigateToSite(_currentSite!);
                          } else if (_currentClient != null) {
                            await _navigateToClient(_currentClient!);
                          } else {
                            await _loadInitialData();
                          }
                        },
                        child: ListView.builder(
                          itemCount: _currentItems.length,
                          itemBuilder: (context, index) {
                            return _buildItemTile(_currentItems[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: (_currentClient != null || _currentSite != null) &&
              !_isLoading
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  _currentSite != null ? '/add-equipment' : '/add-site',
                  arguments: _currentSite ?? _currentClient,
                );
              },
              child: const Icon(Icons.add),
              tooltip: _currentSite != null ? 'Add Equipment' : 'Add Site',
            )
          : null,
    );
  }
}