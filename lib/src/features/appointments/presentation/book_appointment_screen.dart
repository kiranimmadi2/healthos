import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/application/user_providers.dart';
import '../../doctors/domain/doctor_profile.dart';
import '../application/appointment_providers.dart';
import '../data/appointment_repository.dart';
import '../domain/appointment.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final DoctorProfile doctor;
  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  final _symptomsController = TextEditingController();
  bool _isLoading = false;

  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  DateTime _slotDateTime() {
    final parsed = DateFormat('hh:mm a').parse(_selectedTime!);
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      parsed.hour,
      parsed.minute,
    );
  }

  Future<void> _book() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('Not signed in');
      final profile = await ref.read(userProfileProvider.future);
      final patientName =
          profile?['name'] as String? ?? user.displayName ?? 'Patient';

      final appointment = Appointment(
        id: '',
        patientId: user.uid,
        patientName: patientName,
        doctorId: widget.doctor.uid,
        doctorName: widget.doctor.name,
        specialization: widget.doctor.specialization,
        dateTime: _slotDateTime(),
        status: AppointmentStatus.pending,
        symptoms: _symptomsController.text.trim(),
      );

      await ref.read(appointmentRepositoryProvider).book(appointment);
      if (mounted) _showSuccessDialog();
    } on AppointmentSlotUnavailableException catch (e) {
      if (mounted) {
        setState(() => _selectedTime = null);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'BOOKING REQUESTED',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Requested with ${widget.doctor.name}\n${DateFormat('MMM dd').format(_selectedDate)} at $_selectedTime\nYou will be notified once the doctor confirms.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('RETURN HOME'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 700) {
            return _buildWebSplitLayout(context);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildWebSplitLayout(BuildContext context) {
    final avatarUrl =
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.doctor.name)}&background=6366F1&color=fff&size=512&bold=true';

    return Row(
      children: [
        // Left Panel: Doctor Profile & Branding (50%)
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF1E1B4B),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'doctor_${widget.doctor.uid}',
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(avatarUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.doctor.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.doctor.specialization.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (widget.doctor.hospital.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.doctor.hospital,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildDarkStatCard(
                              Icons.star_rounded,
                              '4.9',
                              Colors.amber,
                            ),
                            _buildDarkStatCard(
                              Icons.verified_user_rounded,
                              'Certified',
                              const Color(0xFF60A5FA),
                            ),
                            _buildDarkStatCard(
                              Icons.location_on_rounded,
                              '2.4km',
                              Colors.grey[300]!,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right Panel: Booking Form (50%)
        Expanded(
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your preferred date and time slot for consultation.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 36),
                    _buildSectionTitle('SELECT DATE'),
                    const SizedBox(height: 16),
                    _buildDateSelector(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('SELECT TIME'),
                    const SizedBox(height: 16),
                    _buildTimeSelector(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('DESCRIBE SYMPTOMS'),
                    const SizedBox(height: 16),
                    _buildSymptomsInput(),
                    const SizedBox(height: 40),
                    _buildConfirmButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final avatarUrl =
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.doctor.name)}&background=6366F1&color=fff&size=512&bold=true';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 0,
          backgroundColor: const Color(0xFF0F172A),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.doctor.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Hero(
                      tag: 'doctor_${widget.doctor.uid}',
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(avatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.doctor.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.doctor.specialization.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF38BDF8),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDarkStatCard(
                          Icons.star_rounded,
                          '4.9',
                          Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        _buildDarkStatCard(
                          Icons.verified_user_rounded,
                          'Certified',
                          const Color(0xFF60A5FA),
                        ),
                        const SizedBox(width: 8),
                        _buildDarkStatCard(
                          Icons.location_on_rounded,
                          '2.4km',
                          Colors.grey[300]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('SELECT DATE'),
                    const SizedBox(height: 16),
                    _buildDateSelector(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('SELECT TIME'),
                    const SizedBox(height: 16),
                    _buildTimeSelector(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('DESCRIBE SYMPTOMS'),
                    const SizedBox(height: 16),
                    _buildSymptomsInput(),
                    const SizedBox(height: 48),
                    _buildConfirmButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDarkStatCard(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: Color(0xFF64748B),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index + 1));
          final isSelected =
              _selectedDate.year == date.year &&
              _selectedDate.month == date.month &&
              _selectedDate.day == date.day;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedDate = date;
              _selectedTime = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.grey.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date).toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[500],
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF0F172A),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelector() {
    final schedule = ref.watch(doctorScheduleProvider(widget.doctor.uid));
    final bookedTimes = schedule.maybeWhen(
      data: (appointments) => {
        for (final appointment in appointments)
          if (appointment.dateTime.year == _selectedDate.year &&
              appointment.dateTime.month == _selectedDate.month &&
              appointment.dateTime.day == _selectedDate.day &&
              (appointment.status == AppointmentStatus.pending ||
                  appointment.status == AppointmentStatus.confirmed))
            DateFormat('hh:mm a').format(appointment.dateTime),
      },
      orElse: () => <String>{},
    );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _timeSlots.map((time) {
        final isSelected = _selectedTime == time;
        final isBooked = bookedTimes.contains(time);
        return GestureDetector(
          onTap: isBooked ? null : () => setState(() => _selectedTime = time),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isBooked
                  ? const Color(0xFFF1F5F9)
                  : isSelected
                  ? const Color(0xFF0F172A)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isBooked
                    ? const Color(0xFFE2E8F0)
                    : isSelected
                    ? const Color(0xFF0F172A)
                    : Colors.grey.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isBooked
                        ? const Color(0xFF94A3B8)
                        : isSelected
                        ? Colors.white
                        : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                if (isBooked) ...[
                  const SizedBox(height: 2),
                  const Text(
                    'BOOKED',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSymptomsInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _symptomsController,
        maxLines: 4,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: const InputDecoration(
          hintText: 'Describe your condition...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _book,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'CONFIRM BOOKING',
                style: TextStyle(letterSpacing: 1.0),
              ),
      ),
    );
  }
}
