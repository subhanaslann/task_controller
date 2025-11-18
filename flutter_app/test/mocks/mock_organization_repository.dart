import 'package:flutter_app/data/models/organization.dart';
import 'package:flutter_app/data/models/organization_stats.dart';
import 'package:flutter_app/data/repositories/organization_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockOrganizationRepository extends Mock implements OrganizationRepository {
  // Mock responses for common scenarios
  
  void mockGetOrganization(Organization organization) {
    when(() => getOrganization()).thenAnswer((_) async => organization);
  }

  void mockGetOrganizationError(Exception error) {
    when(() => getOrganization()).thenThrow(error);
  }

  void mockUpdateOrganization(Organization organization) {
    when(() => updateOrganization(
      name: any(named: 'name'),
      teamName: any(named: 'teamName'),
      maxUsers: any(named: 'maxUsers'),
    )).thenAnswer((_) async => organization);
  }

  void mockGetOrganizationStats(OrganizationStats stats) {
    when(() => getOrganizationStats()).thenAnswer((_) async => stats);
  }

  void mockGetOrganizationStatsError(Exception error) {
    when(() => getOrganizationStats()).thenThrow(error);
  }
}

