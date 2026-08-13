import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/theme.dart';
import '../../../shared/presentation/widgets/hos_states.dart';
import '../../appointments/presentation/book_appointment_screen.dart';
import '../application/doctor_providers.dart';
import '../domain/doctor_profile.dart';

class DoctorListScreen extends ConsumerStatefulWidget {
  const DoctorListScreen({super.key});

  @override
  ConsumerState<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends ConsumerState<DoctorListScreen> {
  /// Brightness-aware semantic colours for this screen.
  HosColors get hos => context.hos;

  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(selectedDoctorQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DoctorProfile> _filter(
    List<DoctorProfile> doctors,
    String category,
    String query,
  ) {
    return doctors.where((doctor) {
      final matchesCategory =
          category == 'All' ||
          doctor.specialization.toLowerCase().contains(category.toLowerCase());
      final q = query.toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          doctor.name.toLowerCase().contains(q) ||
          doctor.specialization.toLowerCase().contains(q) ||
          doctor.hospital.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(availableDoctorsProvider);
    final category = ref.watch(selectedDoctorCategoryProvider);
    final query = ref.watch(selectedDoctorQueryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: doctorsAsync.hosWhen(
            onRetry: () => ref.invalidate(availableDoctorsProvider),
            errorTitle: 'Could not load doctors',
            data: (doctors) {
              final categories = [
                'All',
                'General',
                'Pediatrics',
                'Obstetrics',
                'Internal Med',
                'Dermatology',
                'Mental Health',
                'Cardiology',
                'Orthopedics',
                'Infectious',
                ...{for (final d in doctors) d.specialization},
              ];
              // De-duplicate list preserving order
              final uniqueCategories = categories.toSet().toList();
              final filtered = _filter(doctors, category, query);

              return Column(
                children: [
                  const SizedBox(height: 12),
                  _buildSearchBar(context),
                  _buildCategories(context, uniqueCategories, category),
                  Expanded(
                    child: doctors.isEmpty
                        ? _buildEmptyState(
                            context,
                            'No doctors have joined yet.\nCheck back soon!',
                          )
                        : filtered.isEmpty
                        ? _buildEmptyState(context, 'No specialists match your search.')
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            itemCount: filtered.length + 1,
                            itemBuilder: (context, index) {
                              if (index == filtered.length) {
                                return const SizedBox(height: 100);
                              }
                              return _buildDoctorCard(context, filtered[index]);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: hos.textMuted),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: hos.textSecondary,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B).withOpacity(0.75)
              : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF334155)
                : Colors.white.withOpacity(0.9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            ref.read(selectedDoctorQueryProvider.notifier).setQuery(value);
          },
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: hos.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search specialists...',
            icon: Icon(
              Icons.search_rounded,
              color: hos.brand,
              size: 22,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintStyle: TextStyle(
              color: hos.textMuted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(
      BuildContext context, List<String> categories, String selectedCategory) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 24),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.toLowerCase() == selectedCategory.toLowerCase();
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: ActionChip(
              onPressed: () {
                ref.read(selectedDoctorCategoryProvider.notifier).setCategory(cat);
              },
              label: Text(cat.toUpperCase()),
              backgroundColor: isSelected
                  ? (hos.textPrimary)
                  : (isDark
                      ? const Color(0xFF1E293B).withOpacity(0.7)
                      : Colors.white.withOpacity(0.85)),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (hos.textSecondary),
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark
                          ? const Color(0xFF334155)
                          : Colors.grey.withValues(alpha: 0.15)),
                ),
              ),
              elevation: 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorProfile doctor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? const Color(0xFF1E293B).withOpacity(0.75)
        : Colors.white.withOpacity(0.85);
    final borderColor = isDark
        ? const Color(0xFF334155).withOpacity(0.8)
        : const Color(0xFFE2E8F0);
    final nameColor = hos.textPrimary;
    final specColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F8F83);
    final locationColor = hos.textMuted;
    final expBg = hos.brandSoft;
    final expFg = hos.brand;
    final ratingBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5);
    final ratingFg = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);

    void openBooking() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookAppointmentScreen(doctor: doctor),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: openBooking,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'doctor_${doctor.uid}',
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(doctor.name)}&background=2563EB&color=fff&bold=true',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: hos.surface,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              doctor.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                letterSpacing: -0.4,
                                color: nameColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: ratingBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: ratingFg,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '4.9',
                                  style: TextStyle(
                                    color: ratingFg,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialization.toUpperCase(),
                        style: TextStyle(
                          color: specColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.6,
                        ),
                      ),
                      if (doctor.hospital.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: locationColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                doctor.hospital,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: locationColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (doctor.yearsOfExperience != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: expBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 13,
                                    color: expFg,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${doctor.yearsOfExperience} yrs exp',
                                    style: TextStyle(
                                      color: expFg,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: openBooking,
                  icon: const Icon(Icons.calendar_today_rounded, size: 14),
                  label: const Text('Book'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
