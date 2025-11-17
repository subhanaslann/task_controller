import '../datasources/api_service.dart';
import '../models/organization.dart';
import '../models/organization_stats.dart';

class OrganizationRepository {
  final ApiService _apiService;

  OrganizationRepository(this._apiService);

  /// Get current user's organization
  /// Organization ID is determined from JWT token on backend (more secure)
  Future<Organization> getOrganization() async {
    final response = await _apiService.getOrganization();
    return response.organization;
  }

  /// Update current user's organization
  /// Organization ID is determined from JWT token on backend (more secure)
  Future<Organization> updateOrganization({
    String? name,
    String? teamName,
    int? maxUsers,
  }) async {
    final response = await _apiService.updateOrganization(
      UpdateOrganizationRequest(
        name: name,
        teamName: teamName,
        maxUsers: maxUsers,
      ),
    );
    return response.organization;
  }

  /// Get current user's organization statistics
  /// Organization ID is determined from JWT token on backend (more secure)
  Future<OrganizationStats> getOrganizationStats() async {
    final response = await _apiService.getOrganizationStats();
    return response.stats;
  }
}

