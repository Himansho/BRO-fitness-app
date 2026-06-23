import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/user_profile.dart';
import '../home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  int _currentPage = 0;

  // Form data
  final _nameCtrl = TextEditingController();
  double _weight = 75.0;
  double _height = 175.0;
  int _age = 25;
  String _gender = 'male';
  String _goal = 'maintain';
  String _units = 'metric';

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _saveAndContinue();
    }
  }

  double get _bmi => _weight / ((_height / 100) * (_height / 100));
  String get _bmiCategory {
    if (_bmi < 18.5) return 'Underweight';
    if (_bmi < 25.0) return 'Normal';
    if (_bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color get _bmiColor {
    if (_bmi < 18.5) return AppTheme.warningColor;
    if (_bmi < 25.0) return AppTheme.accentColor;
    if (_bmi < 30.0) return AppTheme.warningColor;
    return AppTheme.dangerColor;
  }

  double _tdee() {
    double bmr;
    if (_gender == 'male') {
      bmr = 10 * _weight + 6.25 * _height - 5 * _age + 5;
    } else {
      bmr = 10 * _weight + 6.25 * _height - 5 * _age - 161;
    }
    return bmr * 1.55;
  }

  int _calBudget() {
    final tdee = _tdee();
    switch (_goal) {
      case 'lose': return (tdee - 500).round();
      case 'build': return (tdee + 300).round();
      default: return tdee.round();
    }
  }

  Future<void> _saveAndContinue() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')));
      return;
    }
    final budget = _calBudget();
    final profile = UserProfile(
      name: _nameCtrl.text.trim(),
      weight: _weight,
      height: _height,
      age: _age,
      gender: _gender,
      goal: _goal,
      targetWeight: _goal == 'lose' ? _weight - 5 : _weight + 3,
      units: _units,
      calorieBudget: budget,
      proteinGoal: ((_weight * 2.0)).round(),
      carbsGoal: ((budget * 0.40) / 4).round(),
      fatGoal: ((budget * 0.30) / 9).round(),
    );
    await DatabaseHelper.instance.saveProfile(profile);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(children: [
            // Progress indicator
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcomePage(),
                  _buildBodyStatsPage(),
                  _buildGoalPage(),
                  _buildSummaryPage(),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: List.generate(4, (i) => Expanded(
        child: Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: i <= _currentPage ? AppTheme.primaryColor : AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ))),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        // Logo
        Center(child: Column(children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('BRO', style: TextStyle(
                color: Colors.black, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2,
              )),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Ultra-Private Fitness Journal',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ])),
        const SizedBox(height: 40),
        const Text("What's your name?",
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text("We'll personalize your experience.",
            style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        TextField(
          controller: _nameCtrl,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18),
          decoration: const InputDecoration(
            hintText: 'Your name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 24),
        // Units
        const Text('Preferred Units', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        Row(children: [
          _unitChip('metric', 'Metric (kg/cm)'),
          const SizedBox(width: 12),
          _unitChip('imperial', 'Imperial (lb/ft)'),
        ]),
        const SizedBox(height: 40),
        _bigButton('Continue →', _nextPage),
      ]),
    );
  }

  Widget _buildBodyStatsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        const Text('Your Body Stats',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text("Used to calculate your calorie budget.",
            style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 32),
        // Gender
        const Text('Gender', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        Row(children: [
          _genderChip('male', Icons.male, 'Male'),
          const SizedBox(width: 12),
          _genderChip('female', Icons.female, 'Female'),
        ]),
        const SizedBox(height: 28),
        // Age
        _sliderSection('Age', '$_age years', _age.toDouble(), 15, 80, (v) => setState(() => _age = v.round())),
        const SizedBox(height: 20),
        // Weight
        _sliderSection(
          'Current Weight',
          _units == 'metric' ? '$_weight kg' : '${(_weight * 2.205).toStringAsFixed(1)} lb',
          _weight, 30, 200, (v) => setState(() => _weight = double.parse(v.toStringAsFixed(1))),
        ),
        const SizedBox(height: 20),
        // Height
        _sliderSection(
          'Height',
          _units == 'metric' ? '$_height cm' : '${(_height / 2.54).toStringAsFixed(0)}"',
          _height, 130, 230, (v) => setState(() => _height = double.parse(v.toStringAsFixed(1))),
        ),
        const SizedBox(height: 20),
        // BMI Preview
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _bmiColor.withAlpha(80)),
          ),
          child: Row(children: [
            Icon(Icons.monitor_weight_outlined, color: _bmiColor),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BMI: ${_bmi.toStringAsFixed(1)}',
                  style: TextStyle(color: _bmiColor, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(_bmiCategory, style: TextStyle(color: _bmiColor.withAlpha(180), fontSize: 13)),
            ]),
          ]),
        ),
        const SizedBox(height: 32),
        _bigButton('Continue →', _nextPage),
      ]),
    );
  }

  Widget _buildGoalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        const Text("What's your goal?",
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text("We'll set your calorie and macro targets.",
            style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 32),
        _goalCard('lose', '🔥 Lose Weight',
            'Calorie deficit of ~500 kcal/day', 'Best for fat loss while preserving muscle'),
        const SizedBox(height: 12),
        _goalCard('maintain', '⚖️ Maintain Weight',
            'Eat at maintenance calories', 'Improve fitness without scale changes'),
        const SizedBox(height: 12),
        _goalCard('build', '💪 Build Muscle',
            'Calorie surplus of ~300 kcal/day', 'Maximize muscle growth (lean bulk)'),
        const SizedBox(height: 32),
        // Preview calorie budget
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Your daily budget: ', style: TextStyle(color: Colors.black87, fontSize: 15)),
            Text('${_calBudget()} kcal', style: const TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.w900,
            )),
          ]),
        ),
        const SizedBox(height: 32),
        _bigButton('See Summary →', _nextPage),
      ]),
    );
  }

  Widget _buildSummaryPage() {
    final budget = _calBudget();
    final protein = (_weight * 2.0).round();
    final carbs = ((budget * 0.40) / 4).round();
    final fat = ((budget * 0.30) / 9).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        const Text("You're all set! 🎉",
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text("Here's your personalized plan:",
            style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 32),
        _summaryCard('👤 Profile', [
          'Name: ${_nameCtrl.text.trim().isEmpty ? "—" : _nameCtrl.text.trim()}',
          'Age: $_age  •  Gender: ${_gender[0].toUpperCase() + _gender.substring(1)}',
          'Weight: $_weight kg  •  Height: $_height cm',
          'BMI: ${_bmi.toStringAsFixed(1)} (${_bmiCategory})',
        ]),
        const SizedBox(height: 12),
        _summaryCard('🎯 Daily Targets', [
          'Calories: $budget kcal',
          'Protein: ${protein}g  •  Carbs: ${carbs}g  •  Fat: ${fat}g',
          'Water: 2,500 ml  •  Steps: 8,000',
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withAlpha(60)),
          ),
          child: Row(children: [
            const Icon(Icons.lock_outline, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 10),
            const Expanded(child: Text(
              '100% offline & private. Your data never leaves your device.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            )),
          ]),
        ),
        const SizedBox(height: 32),
        _bigButton("Let's Go! 🚀", _nextPage),
      ]),
    );
  }

  // Helper widgets
  Widget _unitChip(String value, String label) {
    final selected = _units == value;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _units = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor.withAlpha(30) : AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.primaryColor : AppTheme.bgSurface),
        ),
        child: Center(child: Text(label,
            style: TextStyle(color: selected ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal))),
      ),
    ));
  }

  Widget _genderChip(String value, IconData icon, String label) {
    final selected = _gender == value;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor.withAlpha(30) : AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.primaryColor : Colors.transparent),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: selected ? AppTheme.primaryColor : AppTheme.textMuted, size: 28),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: selected ? AppTheme.primaryColor : AppTheme.textSecondary)),
        ]),
      ),
    ));
  }

  Widget _sliderSection(String label, String valueText, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        Text(valueText, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 16)),
      ]),
      Slider(min: min, max: max, value: value.clamp(min, max), onChanged: onChanged,
          divisions: ((max - min)).round()),
    ]);
  }

  Widget _goalCard(String value, String title, String subtitle, String detail) {
    final selected = _goal == value;
    return GestureDetector(
      onTap: () => setState(() => _goal = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor.withAlpha(20) : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppTheme.primaryColor : AppTheme.bgSurface, width: 1.5),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: selected ? AppTheme.primaryColor : AppTheme.textPrimary,
                fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 2),
            Text(detail, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ])),
          if (selected)
            const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 24),
        ]),
      ),
    );
  }

  Widget _summaryCard(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.bgSurface),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 10),
        ...items.map((i) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(i, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        )),
      ]),
    );
  }

  Widget _bigButton(String label, VoidCallback onTap) {
    return SizedBox(width: double.infinity,
      child: ElevatedButton(onPressed: onTap, child: Text(label)));
  }
}
