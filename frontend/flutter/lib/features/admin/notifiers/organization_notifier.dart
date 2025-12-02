import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/organization.dart';
import '../../../data/models/organization_stats.dart';
import '../../../data/repositories/organization_repository.dart';

// Sentinel value to distinguish "not provided" from "explicitly null"
const _undefined = Object();

class OrganizationState {
  final Organization? organization;
  final OrganizationStats? stats;
  final bool isLoading;
  final String? error;

  OrganizationState({
    this.organization,
    this.stats,
    this.isLoading = false,
    this.error,
  });

  OrganizationState copyWith({
    Organization? organization,
    OrganizationStats? stats,
    bool? isLoading,
    Object? error = _undefined,
  }) {
    return OrganizationState(
      organization: organization ?? this.organization,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _undefined) ? this.error : error as String?,
    );
  }
}

class OrganizationNotifier extends StateNotifier<OrganizationState> {
  final OrganizationRepository _repository;

  OrganizationNotifier(this._repository) : super(OrganizationState());

  /// Fetch current user's organization (from JWT token)
  Future<void> fetchOrganization() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final organization = await _repository.getOrganization();
      state = state.copyWith(organization: organization, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load organization: ${e.toString()}',
      );
    }
  }

  /// Fetch current user's organization statistics (from JWT token)
  Future<void> fetchStats() async {
    try {
      final stats = await _repository.getOrganizationStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load statistics: ${e.toString()}',
      );
    }
  }

  /// Update current user's organization (from JWT token)
  Future<void> updateOrganization({
    String? name,
    String? teamName,
    int? maxUsers,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedOrg = await _repository.updateOrganization(
        name: name,
        teamName: teamName,
        maxUsers: maxUsers,
      );
      state = state.copyWith(organization: updatedOrg, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update organization: ${e.toString()}',
      );
    }
  }

  /// Refresh organization data and statistics
  Future<void> refresh() async {
    await fetchOrganization();
    await fetchStats();
  }
}

