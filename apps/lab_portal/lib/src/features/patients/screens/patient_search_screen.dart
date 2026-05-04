import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/repository_providers.dart';

class PatientSearchScreen extends ConsumerStatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  ConsumerState<PatientSearchScreen> createState() =>
      _PatientSearchScreenState();
}

class _PatientSearchScreenState extends ConsumerState<PatientSearchScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  Patient? _searchResult;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPatient() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _searchResult = null;
    });

    try {
      final repo = ref.read(patientRepoProvider);

      Patient? patient;
      if (query.toUpperCase().startsWith('HOS-') ||
          query.toUpperCase().startsWith('HID')) {
        patient = await repo.getByHealthId(query);
      } else {
        final results = await repo.search(query, limit: 1);
        patient = results.isNotEmpty ? results.first : null;
      }

      if (patient != null) {
        setState(() {
          _searchResult = patient;
        });
      } else {
        setState(() {
          _errorMessage = 'No patient found for "$query"';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed: ${e.toString()}';
      });
    } finally {
      setState(() => _isSearching = false);
    }
  }

  String _calculateAge(DateTime? dob) {
    if (dob == null) return 'N/A';
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return '$age';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HosPageContainer(
        center: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text('Patient Search', style: AppTypography.h1),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Search for a patient by their Health ID to upload reports.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                SizedBox(
                  width: 400,
                  child: HosTextField(
                    controller: _searchController,
                    label: 'Health ID',
                    hint: 'Enter Health ID (e.g., HOS-2026-ABCD) or name',
                    prefixIcon: Icons.search,
                    onSubmitted: (_) => _searchPatient(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                HosButton(
                  label: 'Search',
                  onPressed: _searchPatient,
                  isLoading: _isSearching,
                  icon: Icons.search,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_errorMessage != null)
              HosCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        _errorMessage!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_searchResult != null) ...[
              HosCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              (_searchResult!.fullName ?? 'U')[0].toUpperCase(),
                              style: AppTypography.h2.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _searchResult!.fullName ?? 'Unknown',
                                style: AppTypography.h3,
                              ),
                              Text(
                                _searchResult!.healthId,
                                style: AppTypography.bodySmall.copyWith(
                                  fontFamily: 'monospace',
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: AppSpacing.xl),
                      Row(
                        children: [
                          _DetailItem(
                            label: 'Age',
                            value: _calculateAge(_searchResult!.dateOfBirth),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          _DetailItem(
                            label: 'Gender',
                            value: _searchResult!.gender ?? 'N/A',
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          _DetailItem(
                            label: 'Phone',
                            value: _searchResult!.phone,
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          _DetailItem(
                            label: 'Blood Group',
                            value: _searchResult!.bloodGroup ?? 'N/A',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      HosButton(
                        label: 'Upload Report for This Patient',
                        onPressed: () {
                          context.go('/upload');
                        },
                        icon: Icons.upload_file,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (!_isSearching &&
                _searchResult == null &&
                _errorMessage == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_search_outlined,
                        size: 80,
                        color: AppColors.textSecondary
                            .withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Search for a patient using their Health ID',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.bodyMedium),
      ],
    );
  }
}
