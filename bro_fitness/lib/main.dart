import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'database/database_helper.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize database
  await DatabaseHelper.instance.database;

  runApp(const BroFitnessApp());
}

class BroFitnessApp extends StatelessWidget {
  const BroFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BRO Fitness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _AppEntry(),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _checking = true;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final profile = await DatabaseHelper.instance.getProfile();
    setState(() {
      _hasProfile = profile != null;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('BRO', style: TextStyle(
              color: AppTheme.primaryColor, fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: 8,
            )),
            SizedBox(height: 8),
            Text('FITNESS JOURNAL', style: TextStyle(
              color: AppTheme.textSecondary, fontSize: 14, letterSpacing: 4,
            )),
            SizedBox(height: 40),
            SizedBox(
              width: 32, height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2, color: AppTheme.primaryColor,
              ),
            ),
          ]),
        ),
      );
    }

    if (!_hasProfile) {
      return const OnboardingScreen();
    }

    return const HomeScreen();
  }
}
