import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Company (Client) CRUD endpoint
class CompanyEndpoint extends Endpoint {
  /// Get all active companies (excluding system companies by default)
  Future<List<Company>> getAllCompanies(
    Session session, {
    bool includeSystem = false,
  }) async {
    if (includeSystem) {
      return await Company.db.find(
        session,
        where: (t) => t.isActive.equals(true),
        orderBy: (t) => t.name,
      );
    } else {
      return await Company.db.find(
        session,
        where: (t) => t.isActive.equals(true) & t.isSystem.equals(false),
        orderBy: (t) => t.name,
      );
    }
  }

  /// Get company by UUID
  Future<Company?> getCompanyByUuid(Session session, String uuid) async {
    return await Company.db.findFirstRow(
      session,
      where: (t) => t.uuid.equals(uuid),
    );
  }

  /// Create new company
  Future<Company> createCompany(
    Session session,
    String name,
    String? description,
    String createdBy,
  ) async {
    // Check for duplicate name
    final existing = await Company.db.findFirstRow(
      session,
      where: (t) => t.name.equals(name),
    );

    if (existing != null) {
      throw Exception('Company with name "$name" already exists');
    }

    final company = Company(
      uuid: _generateUuid(),
      name: name,
      description: description,
      isSystem: false,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    await Company.db.insertRow(session, company);
    return company;
  }

  /// Update company
  Future<Company> updateCompany(
    Session session,
    String uuid,
    String? name,
    String? description,
  ) async {
    final company = await getCompanyByUuid(session, uuid);
    if (company == null) {
      throw Exception('Company not found');
    }

    if (name != null) company.name = name;
    if (description != null) company.description = description;
    company.updatedAt = DateTime.now();

    await Company.db.updateRow(session, company);
    return company;
  }

  /// Soft delete company
  Future<void> deleteCompany(Session session, String uuid) async {
    final company = await getCompanyByUuid(session, uuid);
    if (company == null) {
      throw Exception('Company not found');
    }

    if (company.isSystem) {
      throw Exception('Cannot delete system company');
    }

    company.isActive = false;
    company.updatedAt = DateTime.now();
    await Company.db.updateRow(session, company);
  }

  String _generateUuid() {
    return '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond % 10000}';
  }
}
