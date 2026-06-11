import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_repository.dart';
import '../../widgets/responsive_layout.dart';

class DoctorHomeScreen extends ConsumerStatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  ConsumerState<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends ConsumerState<DoctorHomeScreen> {
  int _currentIndex = 0;

  final _destinations = const [
    NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    NavigationDestination(icon: Icon(Icons.people), label: 'Patients'),
    NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Schedule'),
  ];

  final _screens = [
    const Center(child: Text('Doctor Dashboard')),
    const Center(child: Text('My Patients')),
    const Center(child: Text('Schedule')),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Scaffold(
        appBar: _buildAppBar(),
        body: _screens[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: _destinations,
        ),
      ),
      desktop: Scaffold(
        appBar: _buildAppBar(),
        body: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.of(context).size.width > 1200,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              labelType: MediaQuery.of(context).size.width > 1200 
                  ? NavigationRailLabelType.none 
                  : NavigationRailLabelType.all,
              destinations: _destinations.map((d) => NavigationRailDestination(
                icon: d.icon,
                label: Text(d.label),
              )).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: _screens[_currentIndex],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('HealthOS Doctor'),
      actions: [
        IconButton(
          onPressed: () => ref.read(authRepositoryProvider).signOut(),
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }
}
