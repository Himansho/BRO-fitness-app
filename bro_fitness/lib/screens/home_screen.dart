import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';
import '../database/database_helper.dart';
import '../models/user_profile.dart';
import 'dashboard/dashboard_screen.dart';
import 'journal/journal_screen.dart';
import 'photos/photos_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  UserProfile? _profile;
  String _activeDate = _todayStr();
  bool _loading = true;

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await DatabaseHelper.instance.getProfile();
    setState(() {
      _profile = p;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    if (_profile == null) {
      return const Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Center(child: Text('Profile not found. Please restart.',
            style: TextStyle(color: AppTheme.textPrimary))),
      );
    }

    final screens = [
      DashboardScreen(
        profile: _profile!,
        activeDate: _activeDate,
        onRefresh: _loadProfile,
      ),
      JournalScreen(
        profile: _profile!,
        activeDate: _activeDate,
        onDateChanged: (d) => setState(() => _activeDate = d),
      ),
      const PhotosScreen(),
      ReportsScreen(profile: _profile!),
      SettingsScreen(
        profile: _profile!,
        onProfileUpdated: _loadProfile,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgCard,
          border: Border(top: BorderSide(color: Color(0xFF1E1E2E), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_calendar_outlined),
              activeIcon: Icon(Icons.edit_calendar),
              label: 'Journal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_camera_outlined),
              activeIcon: Icon(Icons.photo_camera),
              label: 'Photos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
