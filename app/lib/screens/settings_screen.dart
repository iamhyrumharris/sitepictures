import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import '../models/company.dart';
import 'package:package_info_plus/package_info_plus.dart';

// T054: Settings screen with sync controls
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SyncService _syncService = SyncService();
  final StorageService _storageService = StorageService();

  User? _currentUser;
  Company? _currentCompany;
  bool _isLoading = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  int _pendingSyncCount = 0;
  int _totalPhotoCount = 0;
  double _storageUsedGB = 0.0;

  // Sync settings
  bool _autoSync = true;
  bool _syncOnWifiOnly = true;
  bool _syncFullResolution = true;
  int _syncIntervalMinutes = 15;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user and company data
      final user = await _storageService.getCurrentUser();
      final company = await _storageService.getCurrentCompany();

      // Load sync statistics
      final lastSync = await _syncService.getLastSyncTime();
      final pendingCount = await _syncService.getPendingSyncCount();
      final photoCount = await _storageService.getTotalPhotoCount();
      final storageUsed = await _storageService.getStorageUsedGB();

      // Load sync preferences
      final preferences = user?.preferences ?? {};

      setState(() {
        _currentUser = user;
        _currentCompany = company;
        _lastSyncTime = lastSync;
        _pendingSyncCount = pendingCount;
        _totalPhotoCount = photoCount;
        _storageUsedGB = storageUsed;

        _autoSync = preferences['autoSync'] ?? true;
        _syncOnWifiOnly = preferences['syncOnWifiOnly'] ?? true;
        _syncFullResolution = preferences['syncFullResolution'] ?? true;
        _syncIntervalMinutes = preferences['syncIntervalMinutes'] ?? 15;
      });
    } catch (e) {
      _showError('Failed to load settings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performManualSync() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      final result = await _syncService.performSync();

      if (result.success) {
        _showSuccess('Sync completed: ${result.itemsSynced} items synced');
        _loadSettings(); // Reload to update counts
      } else {
        _showError('Sync failed: ${result.error}');
      }
    } catch (e) {
      _showError('Sync error: $e');
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _updateSyncSetting(String key, dynamic value) async {
    try {
      if (_currentUser != null) {
        final preferences = Map<String, dynamic>.from(_currentUser!.preferences);
        preferences[key] = value;

        await _storageService.updateUserPreferences(_currentUser!.id, preferences);

        // Update local state
        setState(() {
          switch (key) {
            case 'autoSync':
              _autoSync = value;
              break;
            case 'syncOnWifiOnly':
              _syncOnWifiOnly = value;
              break;
            case 'syncFullResolution':
              _syncFullResolution = value;
              break;
            case 'syncIntervalMinutes':
              _syncIntervalMinutes = value;
              break;
          }
        });

        // Update sync service settings
        if (key == 'autoSync') {
          if (value) {
            await _syncService.startBackgroundSync(_syncIntervalMinutes);
          } else {
            await _syncService.stopBackgroundSync();
          }
        }
      }
    } catch (e) {
      _showError('Failed to update setting: $e');
    }
  }

  Widget _buildSyncSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sync Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isSyncing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  TextButton.icon(
                    onPressed: _pendingSyncCount > 0 ? _performManualSync : null,
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Now'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Sync statistics
            _buildStatRow(
              Icons.cloud_upload_outlined,
              'Pending Sync',
              '$_pendingSyncCount items',
              color: _pendingSyncCount > 0 ? Colors.orange : Colors.green,
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              Icons.access_time,
              'Last Sync',
              _lastSyncTime != null
                  ? _formatTimeAgo(_lastSyncTime!)
                  : 'Never',
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              Icons.photo_library,
              'Total Photos',
              '$_totalPhotoCount',
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              Icons.storage,
              'Storage Used',
              '${_storageUsedGB.toStringAsFixed(2)} GB',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSettingsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sync Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Auto Sync'),
              subtitle: const Text('Automatically sync when online'),
              value: _autoSync,
              onChanged: (value) => _updateSyncSetting('autoSync', value),
            ),

            SwitchListTile(
              title: const Text('WiFi Only'),
              subtitle: const Text('Only sync when connected to WiFi'),
              value: _syncOnWifiOnly,
              onChanged: _autoSync
                  ? (value) => _updateSyncSetting('syncOnWifiOnly', value)
                  : null,
            ),

            SwitchListTile(
              title: const Text('Full Resolution'),
              subtitle: const Text('Sync photos at full resolution'),
              value: _syncFullResolution,
              onChanged: (value) => _updateSyncSetting('syncFullResolution', value),
            ),

            ListTile(
              title: const Text('Sync Interval'),
              subtitle: Text('Every $_syncIntervalMinutes minutes'),
              trailing: DropdownButton<int>(
                value: _syncIntervalMinutes,
                items: [5, 15, 30, 60].map((minutes) {
                  return DropdownMenuItem(
                    value: minutes,
                    child: Text('$minutes min'),
                  );
                }).toList(),
                onChanged: _autoSync
                    ? (value) {
                        if (value != null) {
                          _updateSyncSetting('syncIntervalMinutes', value);
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Device Name'),
              subtitle: Text(_currentUser?.deviceName ?? 'Unknown'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editDeviceName,
              ),
            ),

            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text('Device ID'),
              subtitle: Text(
                _currentUser?.id ?? 'Unknown',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyToClipboard(_currentUser?.id ?? ''),
              ),
            ),

            if (_currentCompany != null)
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Company'),
                subtitle: Text(_currentCompany!.name),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final info = snapshot.data!;
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('App Version'),
                        subtitle: Text('${info.version} (${info.buildNumber})'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.code),
                        title: const Text('App Name'),
                        subtitle: Text(info.appName),
                      ),
                    ],
                  );
                }
                return const CircularProgressIndicator();
              },
            ),

            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () => _showHelpDialog(),
            ),

            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Terms & Privacy'),
              onTap: () => _showTermsDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _editDeviceName() async {
    final controller = TextEditingController(text: _currentUser?.deviceName);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Device Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Device Name',
            hintText: 'e.g., John\'s iPhone',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && _currentUser != null) {
      try {
        await _storageService.updateUserDeviceName(_currentUser!.id, result);
        _loadSettings();
        _showSuccess('Device name updated');
      } catch (e) {
        _showError('Failed to update device name: $e');
      }
    }
  }

  void _copyToClipboard(String text) {
    // TODO: Implement clipboard copy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Text(
            'FieldPhoto Pro Help\n\n'
            '• Quick Capture: Press camera button to take photos\n'
            '• Navigation: Use breadcrumbs to navigate hierarchy\n'
            '• Search: Find photos and equipment quickly\n'
            '• Sync: Photos sync automatically when online\n\n'
            'For support, contact: support@fieldphoto.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Privacy'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service & Privacy Policy\n\n'
            '• Your data is stored locally on device\n'
            '• Photos sync only with your company server\n'
            '• No telemetry or analytics without consent\n'
            '• GPS data is used only for photo organization\n'
            '• Device-based authentication protects your data\n\n'
            'Last updated: 2025-01-01',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildSyncSection(),
                  _buildSyncSettingsSection(),
                  _buildDeviceSection(),
                  _buildAboutSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}