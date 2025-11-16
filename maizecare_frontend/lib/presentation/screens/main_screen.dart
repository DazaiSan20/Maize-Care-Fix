import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'dashboard/dashboard_screen.dart';
import 'monitoring/monitoring_daun_screen.dart';
import 'notification/notifikasi_screen.dart';
import 'profile/profil_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MonitoringDaunScreen(),
    NotifikasiScreen(),
    ProfilScreen(),
  ];

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}