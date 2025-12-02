import '../datasources/firebase_service.dart';
import '../models/organization.dart';
import '../models/organization_stats.dart';

class OrganizationRepository {
  final FirebaseService _firebaseService;

  OrganizationRepository(this._firebaseService);

  Future<Organization?> getOrganization() async {
    final orgData = await _firebaseService.getOrganization();
    if (orgData == null) return null;
    return Organization.fromJson(orgData);
  }

  Future<Organization> updateOrganization({
    String? name,
    String? teamName,
    int? maxUsers,
  }) async {
    final orgData = await _firebaseService.updateOrganization({
      if (name != null) 'name': name,
      if (teamName != null) 'teamName': teamName,
      if (maxUsers != null) 'maxUsers': maxUsers,
    });
    return Organization.fromJson(orgData);
  }

  Future<OrganizationStats> getOrganizationStats() async {
    final statsData = await _firebaseService.getOrganizationStats();
    return OrganizationStats.fromJson(statsData);
  }
}
