import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../appointments/presentation/book_appointment_screen.dart';
import '../application/doctor_providers.dart';
import '../domain/doctor_profile.dart';

class DoctorListScreen extends ConsumerStatefulWidget {
  const DoctorListScreen({super.key});

  @override
  ConsumerState<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends ConsumerState<DoctorListScreen> {
  String _query = '';
  String _category = 'All';

  List<DoctorProfile> _filter(List<DoctorProfile> doctors) {
    return doctors.where((doctor) {
      final matchesCategory =
          _category == 'All' || doctor.specialization == _category;
      final q = _query.toLowerCase();
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'SPECIALISTS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: doctorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (doctors) {
          final categories = [
            'All',
            ...{for (final d in doctors) d.specialization},
          ];
          final filtered = _filter(doctors);

          return Column(
            children: [
              _buildSearchBar(),
              _buildCategories(categories),
              Expanded(
                child: doctors.isEmpty
                    ? _buildEmptyState(
                        'No doctors have joined yet.\nCheck back soon!',
                      )
                    : filtered.isEmpty
                    ? _buildEmptyState('No specialists match your search.')
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
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _query = value),
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            hintText: 'Search specialists...',
            icon: Icon(
              Icons.search_rounded,
              color: Color(0xFF2563EB),
              size: 22,
            ),
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(List<String> categories) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 24),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _category;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: ActionChip(
              onPressed: () => setState(() => _category = category),
              label: Text(category.toUpperCase()),
              backgroundColor: isSelected
                  ? const Color(0xFF0F172A)
                  : Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.grey.withValues(alpha: 0.1),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'doctor_${doctor.uid}',
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(doctor.name)}&background=6366F1&color=fff&bold=true',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialization.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF0F8F83),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
                if (doctor.hospital.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    doctor.hospital,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (doctor.yearsOfExperience != null) ...[
                      const Icon(
                        Icons.work_history_rounded,
                        color: Color(0xFF2563EB),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${doctor.yearsOfExperience} yrs',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'AVAILABLE',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BookAppointmentScreen(doctor: doctor),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
