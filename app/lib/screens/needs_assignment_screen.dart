import 'package:flutter/material.dart';
import 'dart:io';
import '../models/photo.dart';
import '../models/equipment.dart';
import '../models/client.dart';
import '../models/site.dart';
import '../services/storage_service.dart';
import '../services/file_service.dart';
import '../services/gps_service.dart';

// T056: Needs Assignment folder screen
class NeedsAssignmentScreen extends StatefulWidget {
  const NeedsAssignmentScreen({Key? key}) : super(key: key);

  @override
  State<NeedsAssignmentScreen> createState() => _NeedsAssignmentScreenState();
}

class _NeedsAssignmentScreenState extends State<NeedsAssignmentScreen> {
  final StorageService _storageService = StorageService();
  final FileService _fileService = FileService();
  final GPSService _gpsService = GPSService();

  List<Photo> _unassignedPhotos = [];
  bool _isLoading = true;
  bool _isBatchMode = false;
  Set<String> _selectedPhotoIds = {};

  // Assignment options
  Equipment? _selectedEquipment;
  Site? _selectedSite;
  Client? _selectedClient;

  @override
  void initState() {
    super.initState();
    _loadUnassignedPhotos();
  }

  Future<void> _loadUnassignedPhotos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load photos that need assignment (no equipment ID)
      final photos = await _storageService.getUnassignedPhotos();

      // Sort by capture date (newest first)
      photos.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));

      setState(() {
        _unassignedPhotos = photos;
      });

    } catch (e) {
      _showError('Failed to load unassigned photos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _autoAssignByGPS() async {
    int assignedCount = 0;
    int failedCount = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Auto-Assigning Photos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing GPS coordinates...'),
          ],
        ),
      ),
    );

    try {
      for (final photo in _unassignedPhotos) {
        if (photo.latitude != null && photo.longitude != null) {
          // Find equipment/site based on GPS boundaries
          final detectedLocation = await _gpsService.detectLocationBoundary(
            photo.latitude!,
            photo.longitude!,
          );

          if (detectedLocation != null) {
            await _storageService.assignPhotoToEquipment(
              photo.id,
              detectedLocation.equipmentId ?? detectedLocation.siteId!,
            );
            assignedCount++;
          } else {
            failedCount++;
          }
        } else {
          failedCount++;
        }
      }

      Navigator.pop(context); // Close progress dialog

      _showSuccess(
        'Auto-assignment complete:\n'
        '$assignedCount photos assigned\n'
        '$failedCount photos require manual assignment',
      );

      _loadUnassignedPhotos();

    } catch (e) {
      Navigator.pop(context); // Close progress dialog
      _showError('Auto-assignment failed: $e');
    }
  }

  Future<void> _assignSelectedPhotos() async {
    if (_selectedPhotoIds.isEmpty) return;

    // Show assignment dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AssignmentDialog(
        photoCount: _selectedPhotoIds.length,
      ),
    );

    if (result != null && result['equipment'] != null) {
      try {
        final equipment = result['equipment'] as Equipment;

        for (final photoId in _selectedPhotoIds) {
          await _storageService.assignPhotoToEquipment(photoId, equipment.id);
        }

        _showSuccess(
          'Assigned ${_selectedPhotoIds.length} photos to ${equipment.name}',
        );

        setState(() {
          _isBatchMode = false;
          _selectedPhotoIds.clear();
        });

        _loadUnassignedPhotos();

      } catch (e) {
        _showError('Failed to assign photos: $e');
      }
    }
  }

  Widget _buildPhotoCard(Photo photo) {
    final isSelected = _selectedPhotoIds.contains(photo.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          if (_isBatchMode) {
            setState(() {
              if (isSelected) {
                _selectedPhotoIds.remove(photo.id);
              } else {
                _selectedPhotoIds.add(photo.id);
              }
            });
          } else {
            _assignSinglePhoto(photo);
          }
        },
        onLongPress: () {
          if (!_isBatchMode) {
            setState(() {
              _isBatchMode = true;
              _selectedPhotoIds.add(photo.id);
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Selection checkbox (batch mode)
              if (_isBatchMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        _selectedPhotoIds.add(photo.id);
                      } else {
                        _selectedPhotoIds.remove(photo.id);
                      }
                    });
                  },
                ),

              // Photo thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FutureBuilder<File?>(
                  future: _fileService.getThumbnail(photo.fileName),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Image.file(
                        snapshot.data!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Photo details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateTime(photo.capturedAt),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (photo.notes != null && photo.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          photo.notes!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (photo.latitude != null && photo.longitude != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${photo.latitude!.toStringAsFixed(4)}, '
                              '${photo.longitude!.toStringAsFixed(4)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 14,
                              color: Colors.orange[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'No GPS data',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Quick assign button
              if (!_isBatchMode)
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () => _assignSinglePhoto(photo),
                  tooltip: 'Assign to Equipment',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _assignSinglePhoto(Photo photo) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AssignmentDialog(
        photoCount: 1,
        photo: photo,
      ),
    );

    if (result != null && result['equipment'] != null) {
      try {
        final equipment = result['equipment'] as Equipment;

        await _storageService.assignPhotoToEquipment(photo.id, equipment.id);

        _showSuccess('Photo assigned to ${equipment.name}');
        _loadUnassignedPhotos();

      } catch (e) {
        _showError('Failed to assign photo: $e');
      }
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isBatchMode
            ? '${_selectedPhotoIds.length} selected'
            : 'Needs Assignment (${_unassignedPhotos.length})'),
        leading: _isBatchMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isBatchMode = false;
                    _selectedPhotoIds.clear();
                  });
                },
              )
            : null,
        actions: [
          if (_isBatchMode) ...[
            if (_selectedPhotoIds.length < _unassignedPhotos.length)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedPhotoIds = _unassignedPhotos.map((p) => p.id).toSet();
                  });
                },
                child: const Text('Select All', style: TextStyle(color: Colors.white)),
              )
            else
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedPhotoIds.clear();
                  });
                },
                child: const Text('Clear', style: TextStyle(color: Colors.white)),
              ),
          ] else ...[
            if (_unassignedPhotos.any((p) => p.latitude != null))
              IconButton(
                icon: const Icon(Icons.gps_fixed),
                onPressed: _autoAssignByGPS,
                tooltip: 'Auto-assign by GPS',
              ),
            if (_unassignedPhotos.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.checklist),
                onPressed: () {
                  setState(() {
                    _isBatchMode = true;
                  });
                },
                tooltip: 'Batch mode',
              ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _unassignedPhotos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.green[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'All photos assigned!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No photos need assignment',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUnassignedPhotos,
                  child: ListView.builder(
                    itemCount: _unassignedPhotos.length,
                    itemBuilder: (context, index) {
                      return _buildPhotoCard(_unassignedPhotos[index]);
                    },
                  ),
                ),
      bottomNavigationBar: _isBatchMode && _selectedPhotoIds.isNotEmpty
          ? BottomAppBar(
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _assignSelectedPhotos,
                        icon: const Icon(Icons.folder),
                        label: Text('Assign ${_selectedPhotoIds.length} Photos'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

// Assignment dialog widget
class _AssignmentDialog extends StatefulWidget {
  final int photoCount;
  final Photo? photo;

  const _AssignmentDialog({
    required this.photoCount,
    this.photo,
  });

  @override
  State<_AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends State<_AssignmentDialog> {
  final StorageService _storageService = StorageService();

  Client? _selectedClient;
  Site? _selectedSite;
  Equipment? _selectedEquipment;

  List<Client> _clients = [];
  List<Site> _sites = [];
  List<Equipment> _equipment = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    try {
      final company = await _storageService.getCurrentCompany();
      if (company != null) {
        final clients = await _storageService.getClientsForCompany(company.id);
        setState(() {
          _clients = clients;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSites(String clientId) async {
    final sites = await _storageService.getSitesForClient(clientId);
    setState(() {
      _sites = sites;
      _selectedSite = null;
      _equipment = [];
      _selectedEquipment = null;
    });
  }

  Future<void> _loadEquipment(String siteId) async {
    final equipment = await _storageService.getEquipmentForSite(siteId);
    setState(() {
      _equipment = equipment;
      _selectedEquipment = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign ${widget.photoCount} Photo${widget.photoCount > 1 ? 's' : ''}'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Client selection
                  DropdownButtonFormField<Client>(
                    decoration: const InputDecoration(
                      labelText: 'Client',
                      prefixIcon: Icon(Icons.business),
                    ),
                    value: _selectedClient,
                    items: _clients.map((client) {
                      return DropdownMenuItem(
                        value: client,
                        child: Text(client.name),
                      );
                    }).toList(),
                    onChanged: (client) {
                      setState(() {
                        _selectedClient = client;
                        if (client != null) {
                          _loadSites(client.id);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Site selection
                  DropdownButtonFormField<Site>(
                    decoration: const InputDecoration(
                      labelText: 'Site',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    value: _selectedSite,
                    items: _sites.map((site) {
                      return DropdownMenuItem(
                        value: site,
                        child: Text(site.name),
                      );
                    }).toList(),
                    onChanged: _selectedClient == null
                        ? null
                        : (site) {
                            setState(() {
                              _selectedSite = site;
                              if (site != null) {
                                _loadEquipment(site.id);
                              }
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // Equipment selection
                  DropdownButtonFormField<Equipment>(
                    decoration: const InputDecoration(
                      labelText: 'Equipment',
                      prefixIcon: Icon(Icons.settings_input_component),
                    ),
                    value: _selectedEquipment,
                    items: _equipment.map((equipment) {
                      return DropdownMenuItem(
                        value: equipment,
                        child: Text(equipment.name),
                      );
                    }).toList(),
                    onChanged: _selectedSite == null
                        ? null
                        : (equipment) {
                            setState(() {
                              _selectedEquipment = equipment;
                            });
                          },
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedEquipment == null
              ? null
              : () {
                  Navigator.pop(context, {
                    'client': _selectedClient,
                    'site': _selectedSite,
                    'equipment': _selectedEquipment,
                  });
                },
          child: const Text('Assign'),
        ),
      ],
    );
  }
}