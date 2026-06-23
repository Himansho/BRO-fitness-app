import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/user_profile.dart';
import '../../models/photo_entry.dart'; // Contains PhotoEntry, BodyMeasurement, WeightLog, WaterLog, SupplementLog

class SettingsScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onProfileUpdated;

  const SettingsScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserProfile _profile;
  List<BodyMeasurement> _measurements = [];

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    final m = await DatabaseHelper.instance.getAllMeasurements();
    setState(() => _measurements = m);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Profile card
        _buildProfileCard(),
        const SizedBox(height: 16),
        _sectionHeader('🎯 Goals & Targets'),
        _buildGoalsCard(),
        const SizedBox(height: 16),
        _sectionHeader('📏 Body Measurements'),
        _buildMeasurementsCard(),
        const SizedBox(height: 16),
        _sectionHeader('⚖️ Weight History'),
        _buildWeightHistoryCard(),
        const SizedBox(height: 16),
        _sectionHeader('🔒 Privacy & Security'),
        _buildPrivacyCard(),
        const SizedBox(height: 16),
        _sectionHeader('ℹ️ About'),
        _buildAboutCard(),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(
        color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700,
      )),
    );
  }

  Widget _buildProfileCard() {
    final bmi = _profile.bmi;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A40)),
      ),
      child: Column(children: [
        // Avatar + name
        Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient, shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(_profile.name.isNotEmpty ? _profile.name[0].toUpperCase() : 'B',
                  style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_profile.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            Text('${_profile.goal == 'lose' ? '🔥 Lose Weight' : _profile.goal == 'build' ? '💪 Build Muscle' : '⚖️ Maintain'} • ${_profile.units}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ])),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
            onPressed: _showEditProfileDialog,
          ),
        ]),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        // Stats grid
        Row(children: [
          _profileStat('Weight', '${_profile.weight} kg', Icons.monitor_weight_outlined),
          _profileStat('Height', '${_profile.height} cm', Icons.height),
          _profileStat('Age', '${_profile.age} yr', Icons.cake_outlined),
          _profileStat('BMI', bmi.toStringAsFixed(1), Icons.analytics_outlined,
              color: bmi < 18.5 ? AppTheme.warningColor : bmi < 25 ? AppTheme.accentColor : AppTheme.dangerColor),
        ]),
      ]),
    );
  }

  Widget _profileStat(String label, String val, IconData icon, {Color? color}) {
    return Expanded(child: Column(children: [
      Icon(icon, color: color ?? AppTheme.primaryColor, size: 20),
      const SizedBox(height: 4),
      Text(val, style: TextStyle(color: color ?? AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
    ]));
  }

  Widget _buildGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E2E))),
      child: Column(children: [
        _goalRow('Daily Calories', '${_profile.calorieBudget} kcal', AppTheme.calorieColor),
        const Divider(height: 16),
        _goalRow('Protein', '${_profile.proteinGoal}g', AppTheme.proteinColor),
        const Divider(height: 16),
        _goalRow('Carbs', '${_profile.carbsGoal}g', AppTheme.carbsColor),
        const Divider(height: 16),
        _goalRow('Fat', '${_profile.fatGoal}g', AppTheme.fatColor),
        const Divider(height: 16),
        _goalRow('Water', '${_profile.waterGoal}ml', const Color(0xFF4FC3F7)),
        const Divider(height: 16),
        _goalRow('Daily Steps', '${_profile.stepGoal}', AppTheme.accentColor),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity,
          child: OutlinedButton(onPressed: _showEditGoalsDialog, child: const Text('Edit Goals'))),
      ]),
    );
  }

  Widget _goalRow(String label, String value, Color color) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
    ]);
  }

  Widget _buildMeasurementsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E2E))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_measurements.isEmpty)
          const Text('No measurements logged yet.', style: TextStyle(color: AppTheme.textMuted))
        else ...[
          Text('Latest: ${_measurements.first.date}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (_measurements.first.chestCm != null)
              _measureBadge('Chest', '${_measurements.first.chestCm}cm'),
            if (_measurements.first.waistCm != null)
              _measureBadge('Waist', '${_measurements.first.waistCm}cm'),
            if (_measurements.first.leftArmCm != null)
              _measureBadge('Arms', '${_measurements.first.leftArmCm}cm'),
            if (_measurements.first.leftThighCm != null)
              _measureBadge('Thighs', '${_measurements.first.leftThighCm}cm'),
          ]),
        ],
        const SizedBox(height: 12),
        SizedBox(width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showAddMeasurementSheet,
            icon: const Icon(Icons.straighten, size: 18),
            label: const Text('Log Measurements'),
          )),
      ]),
    );
  }

  Widget _measureBadge(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(20)),
      child: Text('$label: $val', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
    );
  }

  Widget _buildWeightHistoryCard() {
    return FutureBuilder<List<WeightLog>>(
      future: DatabaseHelper.instance.getWeightLogs(limit: 10),
      builder: (ctx, snap) {
        final weights = snap.data ?? [];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E1E2E))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (weights.isEmpty)
              const Text('No weight logs yet.', style: TextStyle(color: AppTheme.textMuted))
            else ...[
              // Mini chart
              SizedBox(
                height: 60,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weights.take(10).toList().reversed.toList().map((w) {
                    final maxW = weights.map((x) => x.weight).reduce((a, b) => a > b ? a : b);
                    final minW = weights.map((x) => x.weight).reduce((a, b) => a < b ? a : b);
                    final range = maxW - minW;
                    final h = range > 0 ? ((w.weight - minW) / range * 45 + 10) : 30.0;
                    return Expanded(child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: h, color: AppTheme.secondaryColor.withAlpha(200),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
                        ),
                      ]),
                    ));
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Text('${weights.first.weight}kg (latest)  →  ${weights.last.weight}kg (oldest)',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ]),
        );
      },
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E2E))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _privacyRow(Icons.lock_outline, 'AES-256 Encrypted Storage', 'Database encrypted on-device'),
        const Divider(height: 20),
        _privacyRow(Icons.cloud_off, 'Fully Offline', 'No data leaves your device'),
        const Divider(height: 20),
        _privacyRow(Icons.no_accounts, 'No Account Required', 'Zero registration, zero tracking'),
        const Divider(height: 20),
        _privacyRow(Icons.block, 'No Ads or Analytics', 'Zero third-party code'),
      ]),
    );
  }

  Widget _privacyRow(IconData icon, String title, String subtitle) {
    return Row(children: [
      Icon(icon, color: AppTheme.accentColor, size: 22),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
        Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ])),
    ]);
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E2E))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(gradient: AppGradients.primaryGradient, borderRadius: BorderRadius.circular(8)),
            child: const Text('BRO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Fitness Journal', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            Text('v1.0.0  •  Ultra-Private', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ]),
        ]),
        const SizedBox(height: 14),
        const Text('Built for gym lovers who value their privacy.\nAll data stays on your device. Always.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ]),
    );
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _profile.name);
    double weight = _profile.weight;
    double height = _profile.height;
    int age = _profile.age;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setD) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Weight', style: TextStyle(color: AppTheme.textSecondary)),
            Text('${weight.toStringAsFixed(1)} kg', style: const TextStyle(color: AppTheme.primaryColor)),
          ]),
          Slider(value: weight.clamp(30, 250), min: 30, max: 250,
              onChanged: (v) => setD(() => weight = double.parse(v.toStringAsFixed(1)))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Height', style: TextStyle(color: AppTheme.textSecondary)),
            Text('${height.toStringAsFixed(0)} cm', style: const TextStyle(color: AppTheme.primaryColor)),
          ]),
          Slider(value: height.clamp(130, 230), min: 130, max: 230,
              onChanged: (v) => setD(() => height = v.roundToDouble())),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Age', style: TextStyle(color: AppTheme.textSecondary)),
            Text('$age yr', style: const TextStyle(color: AppTheme.primaryColor)),
          ]),
          Slider(value: age.toDouble(), min: 15, max: 80, divisions: 65,
              onChanged: (v) => setD(() => age = v.round())),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final updated = _profile.copyWith(
                name: nameCtrl.text.trim().isEmpty ? _profile.name : nameCtrl.text.trim(),
                weight: weight, height: height, age: age,
              );
              await DatabaseHelper.instance.saveProfile(updated);
              setState(() => _profile = updated);
              widget.onProfileUpdated();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      )),
    );
  }

  void _showEditGoalsDialog() {
    int calBudget = _profile.calorieBudget;
    int protein = _profile.proteinGoal;
    int water = _profile.waterGoal;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setD) => AlertDialog(
        title: const Text('Edit Goals'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Calories', style: TextStyle(color: AppTheme.textSecondary)),
            Text('$calBudget kcal', style: const TextStyle(color: AppTheme.primaryColor)),
          ]),
          Slider(value: calBudget.toDouble(), min: 1000, max: 5000, divisions: 80,
              onChanged: (v) => setD(() => calBudget = (v ~/ 50) * 50)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Protein', style: TextStyle(color: AppTheme.textSecondary)),
            Text('${protein}g', style: const TextStyle(color: AppTheme.proteinColor)),
          ]),
          Slider(value: protein.toDouble(), min: 50, max: 300, divisions: 50,
              onChanged: (v) => setD(() => protein = v.round())),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Water', style: TextStyle(color: AppTheme.textSecondary)),
            Text('${water}ml', style: const TextStyle(color: Color(0xFF4FC3F7))),
          ]),
          Slider(value: water.toDouble(), min: 1000, max: 5000, divisions: 40,
              onChanged: (v) => setD(() => water = (v ~/ 100) * 100)),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final updated = _profile.copyWith(
                calorieBudget: calBudget,
                proteinGoal: protein,
                carbsGoal: ((calBudget * 0.40) / 4).round(),
                fatGoal: ((calBudget * 0.30) / 9).round(),
                waterGoal: water,
              );
              await DatabaseHelper.instance.saveProfile(updated);
              setState(() => _profile = updated);
              widget.onProfileUpdated();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      )),
    );
  }

  void _showAddMeasurementSheet() {
    final Map<String, TextEditingController> ctrls = {
      'Chest': TextEditingController(),
      'Waist': TextEditingController(),
      'Hips': TextEditingController(),
      'Left Arm': TextEditingController(),
      'Right Arm': TextEditingController(),
      'Left Thigh': TextEditingController(),
      'Right Thigh': TextEditingController(),
      'Shoulders': TextEditingController(),
      'Neck': TextEditingController(),
      'Calf': TextEditingController(),
      'Body Fat %': TextEditingController(),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Log Body Measurements',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const Text('All fields optional. Enter in centimeters.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            ...ctrls.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: e.value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '${e.key} ${e.key == 'Body Fat %' ? '(%)' : '(cm)'}',
                ),
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  double? getVal(String k) => double.tryParse(ctrls[k]!.text);
                  final today = DateTime.now();
                  final date = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
                  await DatabaseHelper.instance.insertMeasurement(BodyMeasurement(
                    date: date,
                    chestCm: getVal('Chest'),
                    waistCm: getVal('Waist'),
                    hipsCm: getVal('Hips'),
                    leftArmCm: getVal('Left Arm'),
                    rightArmCm: getVal('Right Arm'),
                    leftThighCm: getVal('Left Thigh'),
                    rightThighCm: getVal('Right Thigh'),
                    shouldersCm: getVal('Shoulders'),
                    neckCm: getVal('Neck'),
                    calfCm: getVal('Calf'),
                    bodyFatPercent: getVal('Body Fat %'),
                  ));
                  _loadMeasurements();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📏 Measurements saved!')));
                },
                child: const Text('Save Measurements'),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
