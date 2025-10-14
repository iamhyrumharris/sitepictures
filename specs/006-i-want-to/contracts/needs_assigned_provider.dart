/// Provider Contract: NeedsAssignedProvider
///
/// Purpose: Manages global and per-client "Needs Assigned" folder state
/// - Load global "Needs Assigned" photos and folders
/// - Load per-client "Needs Assigned" photos and folders
/// - Create per-client "Needs Assigned" on client creation
/// - Filter system clients from user-facing lists

import 'package:flutter/foundation.dart';
import '../../../lib/models/client.dart';
import '../../../lib/models/photo.dart';
import '../../../lib/models/photo_folder.dart';
import '../../../lib/models/quick_save_item.dart';

abstract class NeedsAssignedProvider extends ChangeNotifier {
  /// Global "Needs Assigned" client
  Client? get globalClient;

  /// Photos in global "Needs Assigned" (standalone images)
  List<Photo> get globalPhotos;

  /// Folders in global "Needs Assigned" (Quick Save multi-photo folders)
  List<PhotoFolder> get globalFolders;

  /// Loading state
  bool get isLoading;

  /// Error message (if any)
  String? get errorMessage;

  /// Load global "Needs Assigned" data (photos and folders)
  ///
  /// Fetches photos and folders associated with GLOBAL_NEEDS_ASSIGNED client
  /// Updates globalPhotos and globalFolders lists
  /// Notifies listeners on completion
  Future<void> loadGlobalNeedsAssigned();

  /// Load per-client "Needs Assigned" data
  ///
  /// [clientId]: Client ID
  ///
  /// Fetches photos and folders in client's "Needs Assigned" folder
  /// (Per-client "Needs Assigned" appears at top of client's main sites list)
  Future<List<QuickSaveItem>> loadClientNeedsAssigned(String clientId);

  /// Create per-client "Needs Assigned" folder on client creation
  ///
  /// [client]: Newly created client
  ///
  /// Called automatically during client creation workflow
  /// Creates special "Needs Assigned" folder at top of client's sites
  /// Marks with special flag/icon for visual distinction
  Future<void> createClientNeedsAssigned(Client client);

  /// Filter out system clients from client list
  ///
  /// [clients]: All clients including system clients
  ///
  /// Returns: Only user-created clients (is_system = false)
  ///
  /// Used in client lists, equipment navigator, etc. to hide GLOBAL_NEEDS_ASSIGNED
  List<Client> filterUserClients(List<Client> clients);

  /// Get global "Needs Assigned" client ID constant
  ///
  /// Returns: "GLOBAL_NEEDS_ASSIGNED"
  static String get globalClientId => 'GLOBAL_NEEDS_ASSIGNED';
}

/// Example Usage:
///
/// ```dart
/// // In global "Needs Assigned" page
/// class NeedsAssignedPage extends StatefulWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Consumer<NeedsAssignedProvider>(
///       builder: (context, provider, child) {
///         if (provider.isLoading) {
///           return CircularProgressIndicator();
///         }
///
///         return ListView(
///           children: [
///             // Display standalone photos
///             ...provider.globalPhotos.map((photo) =>
///               PhotoTile(photo: photo)
///             ),
///             // Display folders
///             ...provider.globalFolders.map((folder) =>
///               FolderTile(folder: folder)
///             ),
///           ],
///         );
///       },
///     );
///   }
///
///   @override
///   void initState() {
///     super.initState();
///     // Load data on page open
///     Provider.of<NeedsAssignedProvider>(context, listen: false)
///       .loadGlobalNeedsAssigned();
///   }
/// }
///
/// // In client creation flow
/// final newClient = await _clientService.createClient(name, description);
/// await _needsAssignedProvider.createClientNeedsAssigned(newClient);
///
/// // In client list (filter out system clients)
/// final userClients = _needsAssignedProvider.filterUserClients(allClients);
/// ```
