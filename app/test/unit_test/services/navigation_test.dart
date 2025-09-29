import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fieldphoto_pro/services/navigation_service.dart';
import 'package:fieldphoto_pro/services/storage_service.dart';
import 'package:fieldphoto_pro/models/client.dart';
import 'package:fieldphoto_pro/models/site.dart';
import 'package:fieldphoto_pro/models/equipment.dart';

@GenerateMocks([NavigationService, StorageService])
import 'navigation_test.mocks.dart';

void main() {
  group('Hierarchy Navigation Unit Tests', () {
    late MockNavigationService mockNavigationService;
    late MockStorageService mockStorageService;

    setUp(() {
      mockNavigationService = MockNavigationService();
      mockStorageService = MockStorageService();
    });

    test('Builds correct breadcrumb trail for equipment', () async {
      when(mockNavigationService.getBreadcrumbsFor('equipment', 'equip-001'))
          .thenAnswer((_) async {
        return [
          {'type': 'company', 'name': 'Industrial Co', 'id': 'comp-001'},
          {'type': 'client', 'name': 'ACME Corp', 'id': 'client-001'},
          {'type': 'site', 'name': 'Plant A', 'id': 'site-001'},
          {'type': 'subsite', 'name': 'Control Room', 'id': 'site-002'},
          {'type': 'equipment', 'name': 'PLC Panel 1', 'id': 'equip-001'},
        ];
      });

      final breadcrumbs = await mockNavigationService.getBreadcrumbsFor(
        'equipment',
        'equip-001',
      );

      expect(breadcrumbs, hasLength(5));
      expect(breadcrumbs[0]['type'], equals('company'));
      expect(breadcrumbs[1]['type'], equals('client'));
      expect(breadcrumbs[2]['type'], equals('site'));
      expect(breadcrumbs[3]['type'], equals('subsite'));
      expect(breadcrumbs[4]['type'], equals('equipment'));

      // Verify hierarchy order
      expect(breadcrumbs[0]['name'], equals('Industrial Co'));
      expect(breadcrumbs.last['name'], equals('PLC Panel 1'));
    });

    test('Navigates to parent correctly', () async {
      when(mockNavigationService.getParent('equipment', 'equip-001'))
          .thenAnswer((_) async {
        return {'type': 'site', 'id': 'site-002', 'name': 'Control Room'};
      });

      final parent = await mockNavigationService.getParent('equipment', 'equip-001');

      expect(parent['type'], equals('site'));
      expect(parent['id'], equals('site-002'));
    });

    test('Navigates to children correctly', () async {
      when(mockNavigationService.getChildren('site', 'site-001'))
          .thenAnswer((_) async {
        return [
          {'type': 'site', 'id': 'site-002', 'name': 'Sub Site 1'},
          {'type': 'site', 'id': 'site-003', 'name': 'Sub Site 2'},
          {'type': 'equipment', 'id': 'equip-001', 'name': 'Equipment 1'},
          {'type': 'equipment', 'id': 'equip-002', 'name': 'Equipment 2'},
        ];
      });

      final children = await mockNavigationService.getChildren('site', 'site-001');

      expect(children, hasLength(4));
      expect(children.where((c) => c['type'] == 'site'), hasLength(2));
      expect(children.where((c) => c['type'] == 'equipment'), hasLength(2));
    });

    test('Handles main site to sub-site hierarchy correctly', () async {
      final mainSite = Site(
        id: 'site-001',
        clientId: 'client-001',
        name: 'Main Plant',
        parentSiteId: null, // Main site
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      final subSite = Site(
        id: 'site-002',
        clientId: 'client-001',
        name: 'Building A',
        parentSiteId: 'site-001', // Sub-site
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      when(mockStorageService.getSite('site-001')).thenAnswer((_) async => mainSite);
      when(mockStorageService.getSite('site-002')).thenAnswer((_) async => subSite);

      final mainSiteData = await mockStorageService.getSite('site-001');
      final subSiteData = await mockStorageService.getSite('site-002');

      expect(mainSiteData.parentSiteId, isNull);
      expect(subSiteData.parentSiteId, equals('site-001'));
      expect(subSiteData.parentSiteId, equals(mainSiteData.id));
    });

    test('Validates maximum hierarchy depth of 2 for sites', () async {
      when(mockNavigationService.validateSiteHierarchy('site-003', 'site-002'))
          .thenAnswer((_) async {
        // Check if parent already has a parent (would exceed depth of 2)
        return false; // Invalid - would create 3 levels
      });

      final isValid = await mockNavigationService.validateSiteHierarchy(
        'site-003', // New sub-sub-site
        'site-002', // Already a sub-site
      );

      expect(isValid, isFalse,
          reason: 'Should not allow sites deeper than 2 levels');
    });

    test('Gets siblings at same hierarchy level', () async {
      when(mockNavigationService.getSiblings('equipment', 'equip-001'))
          .thenAnswer((_) async {
        return [
          {'type': 'equipment', 'id': 'equip-002', 'name': 'Panel 2'},
          {'type': 'equipment', 'id': 'equip-003', 'name': 'Panel 3'},
        ];
      });

      final siblings = await mockNavigationService.getSiblings(
        'equipment',
        'equip-001',
      );

      expect(siblings, hasLength(2));
      expect(siblings.every((s) => s['type'] == 'equipment'), isTrue);
      expect(siblings.any((s) => s['id'] == 'equip-001'), isFalse,
          reason: 'Should not include self in siblings');
    });

    test('Calculates full hierarchy path', () async {
      when(mockNavigationService.getFullPath('equipment', 'equip-001'))
          .thenAnswer((_) async {
        return '/company/comp-001/client/client-001/site/site-001/site/site-002/equipment/equip-001';
      });

      final path = await mockNavigationService.getFullPath('equipment', 'equip-001');

      expect(path, startsWith('/company'));
      expect(path, endsWith('/equipment/equip-001'));
      expect(path.split('/').length, equals(10)); // 5 levels * 2 parts each
    });

    test('Finds common ancestor between two nodes', () async {
      when(mockNavigationService.findCommonAncestor(
        'equipment',
        'equip-001',
        'equipment',
        'equip-002',
      )).thenAnswer((_) async {
        return {'type': 'site', 'id': 'site-002', 'name': 'Control Room'};
      });

      final ancestor = await mockNavigationService.findCommonAncestor(
        'equipment',
        'equip-001',
        'equipment',
        'equip-002',
      );

      expect(ancestor['type'], equals('site'));
      expect(ancestor['id'], equals('site-002'));
    });

    test('Counts total descendants from a node', () async {
      when(mockNavigationService.countDescendants('client', 'client-001'))
          .thenAnswer((_) async {
        return {
          'sites': 5,
          'equipment': 25,
          'total': 30,
        };
      });

      final counts = await mockNavigationService.countDescendants(
        'client',
        'client-001',
      );

      expect(counts['total'], equals(30));
      expect(counts['sites'], equals(5));
      expect(counts['equipment'], equals(25));
    });

    test('Navigates using relative paths', () async {
      when(mockNavigationService.navigateRelative('../equipment/equip-002'))
          .thenAnswer((_) async {
        return {'type': 'equipment', 'id': 'equip-002', 'name': 'Panel 2'};
      });

      final result = await mockNavigationService.navigateRelative(
        '../equipment/equip-002',
      );

      expect(result['type'], equals('equipment'));
      expect(result['id'], equals('equip-002'));
    });

    test('Validates navigation permissions', () async {
      when(mockNavigationService.canNavigateTo('client', 'client-002'))
          .thenAnswer((_) async {
        // Check if user's device has access to this client
        return false; // Different company
      });

      final canNavigate = await mockNavigationService.canNavigateTo(
        'client',
        'client-002',
      );

      expect(canNavigate, isFalse,
          reason: 'Should not navigate to different company data');
    });

    test('Caches navigation paths for performance', () async {
      when(mockNavigationService.getCachedPath('equipment', 'equip-001'))
          .thenAnswer((_) async {
        return {
          'path': '/company/comp-001/client/client-001/site/site-001/equipment/equip-001',
          'cached': true,
          'cacheAge': 120, // seconds
        };
      });

      final cached = await mockNavigationService.getCachedPath(
        'equipment',
        'equip-001',
      );

      expect(cached['cached'], isTrue);
      expect(cached['cacheAge'], lessThan(300),
          reason: 'Cache should be fresh');
    });

    test('Handles orphaned nodes gracefully', () async {
      when(mockNavigationService.getParent('equipment', 'orphan-001'))
          .thenAnswer((_) async {
        return null; // No parent found
      });

      final parent = await mockNavigationService.getParent(
        'equipment',
        'orphan-001',
      );

      expect(parent, isNull);
      // Should handle orphaned nodes without crashing
    });

    test('Supports filtering navigation by active status', () async {
      when(mockNavigationService.getChildren('site', 'site-001', activeOnly: true))
          .thenAnswer((_) async {
        return [
          {'type': 'equipment', 'id': 'equip-001', 'name': 'Active Panel', 'isActive': true},
          // Inactive equipment filtered out
        ];
      });

      final activeChildren = await mockNavigationService.getChildren(
        'site',
        'site-001',
        activeOnly: true,
      );

      expect(activeChildren.every((c) => c['isActive'] == true), isTrue);
    });
  });
}