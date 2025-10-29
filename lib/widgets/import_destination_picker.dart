import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/client.dart';
import '../models/destination_context.dart';
import '../models/equipment.dart';
import '../models/import_batch.dart';
import '../models/site.dart';
import '../providers/app_state.dart';
import '../providers/auth_state.dart';
import '../providers/equipment_navigator_provider.dart';
import '../providers/needs_assigned_provider.dart';
import '../services/folder_service.dart';
import '../services/import_service.dart';
import '../widgets/create_folder_dialog.dart';
import '../screens/equipment_navigator_page.dart';

class DestinationSelection {
  const DestinationSelection({
    required this.destination,
    required this.beforeAfterChoice,
  });

  final DestinationContext destination;
  final BeforeAfterChoice beforeAfterChoice;
}

Future<DestinationSelection?> showImportDestinationPicker({
  required BuildContext context,
  required ImportEntryPoint entryPoint,
}) async {
  final appState = context.read<AppState>();

  final Equipment? equipment = await Navigator.of(context).push<Equipment>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (navigatorContext) => ChangeNotifierProvider(
        create: (_) => EquipmentNavigatorProvider(),
        child: const EquipmentNavigatorPage(),
      ),
    ),
  );

  if (equipment == null) {
    return null;
  }

  final folderService = FolderService();
  final folders = await folderService.getFolders(equipment.id);

  Client? client;
  MainSite? mainSite;
  SubSite? subSite;

  if (equipment.clientId != null) {
    client = await appState.getClient(equipment.clientId!);
  } else if (equipment.mainSiteId != null) {
    mainSite = await appState.getMainSite(equipment.mainSiteId!);
    if (mainSite != null) {
      client = await appState.getClient(mainSite.clientId);
    }
  } else if (equipment.subSiteId != null) {
    subSite = await appState.getSubSite(equipment.subSiteId!);
    if (subSite != null) {
      if (subSite.mainSiteId != null) {
        mainSite = await appState.getMainSite(subSite.mainSiteId!);
        if (mainSite != null) {
          client = await appState.getClient(mainSite.clientId);
        }
      } else if (subSite.clientId != null) {
        client = await appState.getClient(subSite.clientId!);
      }
    }
  }

  DestinationSelection buildSelection({
    required DestinationType type,
    String? folderId,
    required BeforeAfterChoice choice,
  }) {
    final clientId =
        client?.id ??
        equipment.clientId ??
        NeedsAssignedProvider.globalClientId;

    return DestinationSelection(
      destination: DestinationContext(
        type: type,
        clientId: clientId,
        mainSiteId: mainSite?.id ?? equipment.mainSiteId,
        subSiteId: subSite?.id ?? equipment.subSiteId,
        equipmentId: equipment.id,
        folderId: folderId,
        label: equipment.name,
      ),
      beforeAfterChoice: choice,
    );
  }

  final DestinationSelection? selection = await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    builder: (sheetContext) {
      final authState = context.read<AuthState>();
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Import destination for ${equipment.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Equipment gallery'),
                subtitle: const Text(
                  'Import into the equipment general photo stream.',
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop(
                    buildSelection(
                      type: DestinationType.equipmentGeneral,
                      choice: BeforeAfterChoice.general,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.create_new_folder_outlined),
                title: const Text('Create new folder…'),
                onTap: () async {
                  final navigator = Navigator.of(sheetContext);
                  final workOrder = await showDialog<String>(
                    context: sheetContext,
                    builder: (dialogContext) => const CreateFolderDialog(),
                  );

                  if (workOrder == null || workOrder.trim().isEmpty) {
                    return;
                  }

                  final beforeAfterChoice = await _promptBeforeAfterChoice(
                    sheetContext,
                    title: 'Import to Before or After?',
                    message: 'Choose the section for the new folder.',
                  );

                  if (beforeAfterChoice == null) {
                    return;
                  }

                  final currentUser = authState.currentUser;
                  if (currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No user signed in. Please sign in and try again.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    final folder = await folderService.createFolder(
                      equipmentId: equipment.id,
                      workOrder: workOrder.trim(),
                      createdBy: currentUser.id,
                    );

                    navigator.pop(
                      buildSelection(
                        type: beforeAfterChoice == BeforeAfterChoice.before
                            ? DestinationType.equipmentBefore
                            : DestinationType.equipmentAfter,
                        folderId: folder.id,
                        choice: beforeAfterChoice,
                      ),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create folder: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              if (folders.isNotEmpty) ...[
                const Divider(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Existing folders',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                for (final folder in folders)
                  ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(folder.name),
                    subtitle: const Text('Choose Before or After'),
                    onTap: () async {
                      final beforeAfterChoice = await _promptBeforeAfterChoice(
                        sheetContext,
                        title: 'Import to Before or After?',
                        message:
                            'Select where to place these photos in "${folder.name}".',
                      );

                      if (beforeAfterChoice == null) {
                        return;
                      }

                      Navigator.of(sheetContext).pop(
                        buildSelection(
                          type: beforeAfterChoice == BeforeAfterChoice.before
                              ? DestinationType.equipmentBefore
                              : DestinationType.equipmentAfter,
                          folderId: folder.id,
                          choice: beforeAfterChoice,
                        ),
                      );
                    },
                  ),
              ],
              const Divider(),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  return selection;
}

Future<BeforeAfterChoice?> _promptBeforeAfterChoice(
  BuildContext context, {
  required String title,
  required String message,
}) {
  BeforeAfterChoice choice = BeforeAfterChoice.before;

  return showDialog<BeforeAfterChoice>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 12),
                RadioListTile<BeforeAfterChoice>(
                  title: const Text('Before'),
                  value: BeforeAfterChoice.before,
                  groupValue: choice,
                  onChanged: (value) => setState(() => choice = value!),
                ),
                RadioListTile<BeforeAfterChoice>(
                  title: const Text('After'),
                  value: BeforeAfterChoice.after,
                  groupValue: choice,
                  onChanged: (value) => setState(() => choice = value!),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(choice),
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );
}
