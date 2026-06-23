import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/user_profile.dart';
import '../../models/meal_log.dart';
import '../../models/workout_log.dart';

class DashboardScreen extends StatefulWidget {
  final UserProfile profile;
  final String activeDate;
  final VoidCallback onRefresh;

  const DashboardScreen({
    super.key,
    required this.profile,
    required this.activeDate,
    required this.onRefresh,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<MealLog> _meals = [];
  List<WorkoutLog> _workouts = [];
  int _waterMl = 0;
  int _streak = 0;
  Map<String, double> _prs = {};
  List<Map<String, dynamic>> _weekData = [];
  bool _loading = true;
  String _chartType = 'calories'; // calories | protein

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(DashboardScreen old) {
    super.didUpdateWidget(old);
    if (old.activeDate != widget.activeDate) _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    final meals = await db.getMealsForDate(widget.activeDate);
    final workouts = await db.getWorkoutsForDate(widget.activeDate);
    final water = await db.getWaterForDate(widget.activeDate);
    final streak = await db.getWorkoutStreakDays();
    final prs = await db.getAllPRs();
    final weekData = await db.getLast7DaysCalories();

    setState(() {
      _meals = meals;
      _workouts = workouts;
      _waterMl = water;
      _streak = streak;
      _prs = prs;
      _weekData = weekData;
      _loading = false;
    });
  }

  double get _totalCalories => _meals.fold(0, (s, m) => s + m.calories);
  double get _totalProtein => _meals.fold(0, (s, m) => s + m.protein);
  double get _totalCarbs => _meals.fold(0, (s, m) => s + m.carbs);
  double get _totalFat => _meals.fold(0, (s, m) => s + m.fat);
  double get _calProgress => (_totalCalories / widget.profile.calorieBudget).clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.bgCard,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A0A1F), Color(0xFF0A0A0F)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Hey, ${widget.profile.name.split(' ')[0]}! 👋',
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
                      Text(_todayLabel(), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ]),
                    if (_streak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppGradients.prGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text('$_streak day streak', style: const TextStyle(
                            color: Colors.black, fontSize: 12, fontWeight: FontWeight.w700,
                          )),
                        ]),
                      ),
                  ]),
                ]),
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)))
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildListDelegate([
                // Calorie Ring Card
                _buildCalorieCard(),
                const SizedBox(height: 12),
                // Macros Row
                _buildMacrosRow(),
                const SizedBox(height: 12),
                // Water Card
                _buildWaterCard(),
                const SizedBox(height: 12),
                // Chart Card
                _buildChartCard(),
                const SizedBox(height: 12),
                // Workouts Today
                _buildWorkoutsCard(),
                const SizedBox(height: 12),
                // PRs Card
                if (_prs.isNotEmpty) _buildPRsCard(),
                const SizedBox(height: 80), // FAB space
              ])),
            ),
        ],
      ),
    );
  }

  Widget _buildCalorieCard() {
    final remaining = (widget.profile.calorieBudget - _totalCalories).toInt();
    final overEaten = remaining < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E1E2E)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Calories', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          Text(overEaten ? '⚠️ Over budget' : '✅ On track',
              style: TextStyle(color: overEaten ? AppTheme.dangerColor : AppTheme.accentColor, fontSize: 12)),
        ]),
        const SizedBox(height: 16),
        // Ring-style progress
        Stack(alignment: Alignment.center, children: [
          SizedBox(width: 160, height: 160,
            child: CircularProgressIndicator(
              value: _calProgress,
              strokeWidth: 14,
              backgroundColor: AppTheme.bgSurface,
              valueColor: AlwaysStoppedAnimation(
                overEaten ? AppTheme.dangerColor : AppTheme.primaryColor,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${_totalCalories.toInt()}',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 32, fontWeight: FontWeight.w900)),
            Text('of ${widget.profile.calorieBudget} kcal',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _caloMiniStat('Eaten', '${_totalCalories.toInt()}', AppTheme.calorieColor),
          Container(width: 1, height: 30, color: AppTheme.bgSurface),
          _caloMiniStat('Remaining', '$remaining', overEaten ? AppTheme.dangerColor : AppTheme.accentColor),
          Container(width: 1, height: 30, color: AppTheme.bgSurface),
          _caloMiniStat('Burned', '${_workouts.length * 250}', AppTheme.warningColor),
        ]),
      ]),
    );
  }

  Widget _caloMiniStat(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
    ]);
  }

  Widget _buildMacrosRow() {
    return Row(children: [
      Expanded(child: _macroCard('Protein', _totalProtein, widget.profile.proteinGoal.toDouble(), AppTheme.proteinColor, 'g')),
      const SizedBox(width: 8),
      Expanded(child: _macroCard('Carbs', _totalCarbs, widget.profile.carbsGoal.toDouble(), AppTheme.carbsColor, 'g')),
      const SizedBox(width: 8),
      Expanded(child: _macroCard('Fat', _totalFat, widget.profile.fatGoal.toDouble(), AppTheme.fatColor, 'g')),
    ]);
  }

  Widget _macroCard(String label, double current, double goal, Color color, String unit) {
    final progress = (current / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E1E2E))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 6),
        Text('${current.toStringAsFixed(0)}$unit',
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
        Text('of ${goal.toInt()}$unit',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress, backgroundColor: AppTheme.bgSurface,
            valueColor: AlwaysStoppedAnimation(color), minHeight: 5,
          ),
        ),
      ]),
    );
  }

  Widget _buildWaterCard() {
    final progress = (_waterMl / widget.profile.waterGoal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E2E))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Row(children: [
            Icon(Icons.water_drop, color: Color(0xFF4FC3F7), size: 18),
            SizedBox(width: 8),
            Text('Water Intake', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          ]),
          Text('${_waterMl}ml / ${widget.profile.waterGoal}ml',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress, backgroundColor: AppTheme.bgSurface, minHeight: 10,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF4FC3F7)),
          ),
        ),
        const SizedBox(height: 12),
        // Quick add buttons
        Row(children: [250, 500, 750].map((ml) => Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: OutlinedButton(
            onPressed: () => _addWater(ml),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 6),
              side: const BorderSide(color: Color(0xFF4FC3F7)),
              foregroundColor: const Color(0xFF4FC3F7),
            ),
            child: Text('+${ml}ml', style: const TextStyle(fontSize: 12)),
          ),
        ))).toList()),
      ]),
    );
  }

  Future<void> _addWater(int ml) async {
    final newTotal = _waterMl + ml;
    await DatabaseHelper.instance.setWaterForDate(widget.activeDate, newTotal);
    setState(() => _waterMl = newTotal);
    if (newTotal >= widget.profile.waterGoal && _waterMl < widget.profile.waterGoal) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('💧 Daily water goal achieved! Great job!')));
      }
    }
  }

  Widget _buildChartCard() {
    if (_weekData.isEmpty) return const SizedBox();
    final maxVal = _weekData.fold<double>(1, (m, d) {
      final v = _chartType == 'calories' ? (d['calories'] as double) : (d['protein'] as double);
      return v > m ? v : m;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E2E))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('7-Day Overview', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          Row(children: [
            _chartToggle('Cal', 'calories'),
            const SizedBox(width: 6),
            _chartToggle('Protein', 'protein'),
          ]),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _weekData.map((d) {
              final val = _chartType == 'calories' ? (d['calories'] as double) : (d['protein'] as double);
              final isToday = d['date'] == widget.activeDate;
              final barH = maxVal > 0 ? (val / maxVal) * 80 : 4.0;
              final goal = _chartType == 'calories'
                  ? widget.profile.calorieBudget.toDouble()
                  : widget.profile.proteinGoal.toDouble();
              final color = val >= goal ? AppTheme.accentColor : AppTheme.primaryColor;
              return Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('${val.toInt()}',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 9),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    height: barH.clamp(4, 80),
                    decoration: BoxDecoration(
                      gradient: isToday ? AppGradients.primaryGradient : null,
                      color: isToday ? null : color.withAlpha(160),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(d['date'].toString().substring(5),
                      style: TextStyle(
                        color: isToday ? AppTheme.primaryColor : AppTheme.textMuted,
                        fontSize: 9,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                      )),
                ]),
              ));
            }).toList(),
          ),
        ),
      ]),
    );
  }

  Widget _chartToggle(String label, String type) {
    final selected = _chartType == type;
    return GestureDetector(
      onTap: () => setState(() => _chartType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor.withAlpha(30) : AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primaryColor : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? AppTheme.primaryColor : AppTheme.textMuted,
          fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        )),
      ),
    );
  }

  Widget _buildWorkoutsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E2E))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Today's Workouts", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          Text('${_workouts.length} exercises',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ]),
        if (_workouts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text('No workouts logged today. Hit the gym! 💪',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13))),
          )
        else ...[
          const SizedBox(height: 12),
          ..._workouts.take(3).map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(w.exerciseName,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14))),
              Text('${w.sets.length} sets • ${w.totalVolume.toInt()}kg vol',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ]),
          )),
          if (_workouts.length > 3)
            Text('+${_workouts.length - 3} more',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ],
      ]),
    );
  }

  Widget _buildPRsCard() {
    final topPRs = _prs.entries.take(4).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E2E)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Text('🏆 Personal Records', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          SizedBox(width: 6),
          Text('(Estimated 1RM)', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        ]),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3, mainAxisSpacing: 8, crossAxisSpacing: 8,
          children: topPRs.map((e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(e.key, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  overflow: TextOverflow.ellipsis)),
              Text('${e.value.toStringAsFixed(1)}kg',
                  style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
          )).toList(),
        ),
      ]),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
