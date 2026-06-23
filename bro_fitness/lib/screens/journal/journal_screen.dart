import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/user_profile.dart';
import '../../models/meal_log.dart';
import '../../models/workout_log.dart';
import '../../models/photo_entry.dart';
import '../../data/food_database.dart';
import '../../data/exercise_database.dart';

class JournalScreen extends StatefulWidget {
  final UserProfile profile;
  final String activeDate;
  final Function(String) onDateChanged;

  const JournalScreen({
    super.key,
    required this.profile,
    required this.activeDate,
    required this.onDateChanged,
  });

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> with SingleTickerProviderStateMixin {
  List<MealLog> _meals = [];
  List<WorkoutLog> _workouts = [];
  int _waterMl = 0;
  bool _loading = true;

  // Rest Timer
  int _restTimerSeconds = 0;
  bool _restTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(JournalScreen old) {
    super.didUpdateWidget(old);
    if (old.activeDate != widget.activeDate) _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    final meals = await db.getMealsForDate(widget.activeDate);
    final workouts = await db.getWorkoutsForDate(widget.activeDate);
    final water = await db.getWaterForDate(widget.activeDate);
    setState(() {
      _meals = meals;
      _workouts = workouts;
      _waterMl = water;
      _loading = false;
    });
  }

  double get _totalCalories => _meals.fold(0, (s, m) => s + m.calories);
  double get _totalProtein => _meals.fold(0, (s, m) => s + m.protein);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.primaryColor,
              child: CustomScrollView(slivers: [
                _buildHeader(),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(delegate: SliverChildListDelegate([
                    // Rest Timer (shown if running)
                    if (_restTimerRunning || _restTimerSeconds > 0) _buildRestTimerCard(),
                    if (_restTimerRunning || _restTimerSeconds > 0) const SizedBox(height: 12),
                    // Daily summary
                    _buildDailySummary(),
                    const SizedBox(height: 16),
                    // Meals section
                    _buildSectionHeader('🍽️ Meals', 'Add Meal', () => _showAddMealSheet()),
                    ..._buildMealItems(),
                    const SizedBox(height: 16),
                    // Workouts section
                    _buildSectionHeader('🏋️ Workouts', 'Add Workout', () => _showAddWorkoutSheet()),
                    ..._buildWorkoutItems(),
                    const SizedBox(height: 80),
                  ])),
                ),
              ]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSelector,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildHeader() {
    final dateObj = DateTime.tryParse(widget.activeDate) ?? DateTime.now();
    final isToday = widget.activeDate == _todayStr();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.bgDark,
      title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppTheme.primaryColor),
          onPressed: () {
            final d = DateTime.parse(widget.activeDate).subtract(const Duration(days: 1));
            widget.onDateChanged(_dateStr(d));
          },
        ),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: dateObj,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppTheme.primaryColor, surface: AppTheme.bgCard,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) widget.onDateChanged(_dateStr(picked));
          },
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(isToday ? 'Today' : '${days[dateObj.weekday - 1]}',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${dateObj.day} ${months[dateObj.month - 1]}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
          onPressed: isToday ? null : () {
            final d = DateTime.parse(widget.activeDate).add(const Duration(days: 1));
            if (!d.isAfter(DateTime.now())) widget.onDateChanged(_dateStr(d));
          },
        ),
      ]),
      centerTitle: true,
    );
  }

  Widget _buildDailySummary() {
    final remaining = widget.profile.calorieBudget - _totalCalories;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF13131A), Color(0xFF1C1C28)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A40)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _miniStat('Eaten', '${_totalCalories.toInt()}', 'kcal', AppTheme.calorieColor),
        _vDivider(),
        _miniStat('Left', '${remaining.toInt()}', 'kcal',
            remaining < 0 ? AppTheme.dangerColor : AppTheme.accentColor),
        _vDivider(),
        _miniStat('Protein', '${_totalProtein.toInt()}', 'g', AppTheme.proteinColor),
        _vDivider(),
        _miniStat('Water', '${(_waterMl / 1000).toStringAsFixed(1)}', 'L', const Color(0xFF4FC3F7)),
      ]),
    );
  }

  Widget _miniStat(String label, String val, String unit, Color c) => Column(children: [
    Text(val, style: TextStyle(color: c, fontSize: 18, fontWeight: FontWeight.w800)),
    Text(unit, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
    Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
  ]);

  Widget _vDivider() => Container(width: 1, height: 36, color: AppTheme.bgSurface);

  Widget _buildSectionHeader(String title, String actionLabel, VoidCallback onAction) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
      TextButton.icon(
        onPressed: onAction,
        icon: const Icon(Icons.add_circle_outline, size: 16),
        label: Text(actionLabel, style: const TextStyle(fontSize: 13)),
      ),
    ]);
  }

  List<Widget> _buildMealItems() {
    if (_meals.isEmpty) {
      return [_emptyState('No meals logged yet.\nTap "Add Meal" to start tracking! 🍽️')];
    }
    // Group by category
    final categories = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    final List<Widget> items = [];
    for (final cat in categories) {
      final catMeals = _meals.where((m) => m.category == cat).toList();
      if (catMeals.isEmpty) continue;
      items.add(Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(cat, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
      ));
      for (final meal in catMeals) {
        items.add(_mealTile(meal));
      }
    }
    // Total macros row
    final totalCal = _meals.fold<double>(0, (s, m) => s + m.calories);
    final totalP = _meals.fold<double>(0, (s, m) => s + m.protein);
    final totalC = _meals.fold<double>(0, (s, m) => s + m.carbs);
    final totalF = _meals.fold<double>(0, (s, m) => s + m.fat);
    items.add(Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _macroTotal('${totalCal.toInt()} kcal', AppTheme.calorieColor),
        _macroTotal('P: ${totalP.toInt()}g', AppTheme.proteinColor),
        _macroTotal('C: ${totalC.toInt()}g', AppTheme.carbsColor),
        _macroTotal('F: ${totalF.toInt()}g', AppTheme.fatColor),
      ]),
    ));
    return items;
  }

  Widget _macroTotal(String text, Color c) =>
      Text(text, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600));

  Widget _mealTile(MealLog meal) {
    return Dismissible(
      key: Key('meal_${meal.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.dangerColor.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.dangerColor),
      ),
      onDismissed: (_) async {
        await DatabaseHelper.instance.deleteMeal(meal.id!);
        _loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E2E))),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.restaurant, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(meal.foodName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            Text('${meal.portionGrams.toInt()}g  •  ${meal.foodCategory}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${meal.calories.toInt()} kcal',
                style: const TextStyle(color: AppTheme.calorieColor, fontWeight: FontWeight.w700)),
            Text('P:${meal.protein.toInt()}g C:${meal.carbs.toInt()}g F:${meal.fat.toInt()}g',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ]),
        ]),
      ),
    );
  }

  List<Widget> _buildWorkoutItems() {
    if (_workouts.isEmpty) {
      return [_emptyState('No workouts logged today.\nTap "Add Workout" to start! 🏋️')];
    }
    return [
      ..._workouts.map((w) => _workoutTile(w)),
      // Volume summary
      Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _macroTotal('${_workouts.length} exercises', AppTheme.primaryColor),
          _macroTotal('${_workouts.fold(0, (s, w) => s + w.sets.length)} sets', AppTheme.secondaryColor),
          _macroTotal('${_workouts.fold(0.0, (s, w) => s + w.totalVolume).toInt()}kg vol', AppTheme.accentColor),
        ]),
      ),
    ];
  }

  Widget _workoutTile(WorkoutLog workout) {
    return Dismissible(
      key: Key('workout_${workout.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.dangerColor.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.dangerColor),
      ),
      onDismissed: (_) async {
        await DatabaseHelper.instance.deleteWorkout(workout.id!);
        _loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: workout.hasPR ? AppTheme.accentColor.withAlpha(100) : const Color(0xFF1E1E2E))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fitness_center, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(workout.exerciseName,
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                if (workout.hasPR) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: AppGradients.prGradient, borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🏆 PR!', style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w700)),
                  ),
                ],
              ]),
              Text('${workout.primaryMuscle}  •  ${workout.sets.length} sets  •  ${workout.totalVolume.toInt()}kg vol',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ])),
            Text('1RM: ${workout.bestOneRM.toStringAsFixed(1)}kg',
                style: const TextStyle(color: AppTheme.accentColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 10),
          // Sets
          Wrap(
            spacing: 6, runSpacing: 6,
            children: workout.sets.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: s.isPR ? AppTheme.accentColor.withAlpha(30) : AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: s.isPR ? AppTheme.accentColor.withAlpha(100) : Colors.transparent),
              ),
              child: Text('${s.weight}kg × ${s.reps}',
                  style: TextStyle(
                    color: s.isPR ? AppTheme.accentColor : AppTheme.textSecondary,
                    fontSize: 12, fontWeight: s.isPR ? FontWeight.w700 : FontWeight.normal,
                  )),
            )).toList(),
          ),
        ]),
      ),
    );
  }

  Widget _buildRestTimerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        const Icon(Icons.timer, color: Colors.black, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Rest Timer', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
          Text(_formatTime(_restTimerSeconds),
              style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900)),
        ])),
        TextButton(
          onPressed: () => setState(() { _restTimerRunning = false; _restTimerSeconds = 0; }),
          style: TextButton.styleFrom(foregroundColor: Colors.black87),
          child: const Text('Done'),
        ),
      ]),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _emptyState(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E1E2E), style: BorderStyle.solid)),
      child: Center(child: Text(text, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          textAlign: TextAlign.center)),
    );
  }

  void _showAddSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('What would you like to add?',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: _addOptionCard('🍽️', 'Meal', 'Log food & calories', () {
              Navigator.pop(context);
              _showAddMealSheet();
            })),
            const SizedBox(width: 12),
            Expanded(child: _addOptionCard('🏋️', 'Workout', 'Log sets & reps', () {
              Navigator.pop(context);
              _showAddWorkoutSheet();
            })),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _addOptionCard('💊', 'Supplement', 'Log your supps', () {
              Navigator.pop(context);
              _showAddSupplementSheet();
            })),
            const SizedBox(width: 12),
            Expanded(child: _addOptionCard('⚖️', 'Weight', 'Log body weight', () {
              Navigator.pop(context);
              _showLogWeightDialog();
            })),
          ]),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  Widget _addOptionCard(String emoji, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A40)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ]),
      ),
    );
  }

  // ─── ADD MEAL SHEET ───
  void _showAddMealSheet() {
    String category = 'Breakfast';
    String search = '';
    FoodItem? selectedFood;
    double portion = 100;
    bool isCustom = false;
    final customNameCtrl = TextEditingController();
    final customCalCtrl = TextEditingController();
    final customProtCtrl = TextEditingController();
    final customCarbCtrl = TextEditingController();
    final customFatCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setBS) {
        final filtered = foodDatabase.where((f) =>
          f.name.toLowerCase().contains(search.toLowerCase()) ||
          f.category.toLowerCase().contains(search.toLowerCase())).toList();

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          builder: (_, sc) => SingleChildScrollView(
            controller: sc,
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Add Meal', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              // Category
              SingleChildScrollView(scrollDirection: Axis.horizontal,
                child: Row(children: ['Breakfast','Lunch','Dinner','Snack'].map((c) =>
                  Padding(padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(label: Text(c), selected: category == c,
                        onSelected: (_) => setBS(() => category = c)))).toList())),
              const SizedBox(height: 16),
              // Search
              TextField(
                decoration: const InputDecoration(hintText: 'Search food...', prefixIcon: Icon(Icons.search)),
                onChanged: (v) => setBS(() { search = v; selectedFood = null; }),
              ),
              const SizedBox(height: 8),
              // Custom toggle
              Row(children: [
                Checkbox(value: isCustom, onChanged: (v) => setBS(() => isCustom = v!),
                    activeColor: AppTheme.primaryColor),
                const Text('Enter custom food', style: TextStyle(color: AppTheme.textSecondary)),
              ]),
              if (isCustom) ...[
                TextField(controller: customNameCtrl, decoration: const InputDecoration(hintText: 'Food name')),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: customCalCtrl, keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Calories'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: customProtCtrl, keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Protein (g)'))),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: customCarbCtrl, keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Carbs (g)'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: customFatCtrl, keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Fat (g)'))),
                ]),
              ] else ...[
                // Food list
                ...filtered.take(20).map((f) {
                  final isSelected = selectedFood?.id == f.id;
                  return GestureDetector(
                    onTap: () => setBS(() => selectedFood = isSelected ? null : f),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor.withAlpha(20) : AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent),
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(6)),
                          child: Text(f.category, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(f.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                          Text('${f.servingUnit}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                        ])),
                        Text('${f.calories.toInt()} kcal',
                            style: const TextStyle(color: AppTheme.calorieColor, fontWeight: FontWeight.w700, fontSize: 13)),
                      ]),
                    ),
                  );
                }),
              ],

              if (selectedFood != null || isCustom) ...[
                const SizedBox(height: 16),
                // Portion
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Portion (grams)', style: TextStyle(color: AppTheme.textSecondary)),
                  Text('${portion.toInt()}g',
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700)),
                ]),
                Slider(
                  value: portion.clamp(5, 1000), min: 5, max: 1000,
                  onChanged: (v) => setBS(() => portion = v.roundToDouble()),
                  divisions: 199,
                ),

                if (selectedFood != null) ...[
                  // Calculated macros preview
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(10)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _macroPreview('${(selectedFood!.calories * portion / 100).toInt()}', 'kcal', AppTheme.calorieColor),
                      _macroPreview('${(selectedFood!.protein * portion / 100).toStringAsFixed(1)}', 'P(g)', AppTheme.proteinColor),
                      _macroPreview('${(selectedFood!.carbs * portion / 100).toStringAsFixed(1)}', 'C(g)', AppTheme.carbsColor),
                      _macroPreview('${(selectedFood!.fat * portion / 100).toStringAsFixed(1)}', 'F(g)', AppTheme.fatColor),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      MealLog meal;
                      if (isCustom) {
                        meal = MealLog(
                          date: widget.activeDate, category: category,
                          foodName: customNameCtrl.text.trim().isEmpty ? 'Custom Food' : customNameCtrl.text.trim(),
                          foodCategory: 'Custom',
                          portionGrams: portion,
                          calories: (double.tryParse(customCalCtrl.text) ?? 0) * portion / 100,
                          protein: (double.tryParse(customProtCtrl.text) ?? 0) * portion / 100,
                          carbs: (double.tryParse(customCarbCtrl.text) ?? 0) * portion / 100,
                          fat: (double.tryParse(customFatCtrl.text) ?? 0) * portion / 100,
                        );
                      } else {
                        final f = selectedFood!;
                        meal = MealLog(
                          date: widget.activeDate, category: category,
                          foodName: f.name, foodCategory: f.category,
                          portionGrams: portion,
                          calories: f.calories * portion / 100,
                          protein: f.protein * portion / 100,
                          carbs: f.carbs * portion / 100,
                          fat: f.fat * portion / 100,
                          fiber: f.fiber * portion / 100,
                          sugar: f.sugar * portion / 100,
                          sodium: f.sodium * portion / 100,
                          servingUnit: f.servingUnit,
                        );
                      }
                      await DatabaseHelper.instance.insertMeal(meal);
                      Navigator.pop(ctx);
                      _loadData();
                    },
                    child: const Text('Add to Log'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ]),
          ),
        );
      }),
    );
  }

  Widget _macroPreview(String val, String label, Color c) => Column(children: [
    Text(val, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 16)),
    Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
  ]);

  // ─── ADD WORKOUT SHEET ───
  void _showAddWorkoutSheet() {
    String search = '';
    ExerciseItem? selectedEx;
    bool isCustom = false;
    final customNameCtrl = TextEditingController();
    final List<Map<String, TextEditingController>> sets = [
      {'weight': TextEditingController(), 'reps': TextEditingController(text: '8')},
    ];
    String previousSession = '';
    String selectedType = 'Strength';

    void loadPrevious(ExerciseItem ex, StateSetter setBS) async {
      final history = await DatabaseHelper.instance.getWorkoutHistoryForExercise(ex.name, limit: 1);
      if (history.isNotEmpty) {
        final last = history.first;
        final setsStr = last.sets.map((s) => '${s.weight}kg×${s.reps}').join(' | ');
        setBS(() => previousSession = 'Last: ${last.date} — $setsStr');
        // Pre-fill with last session values
        if (last.sets.isNotEmpty) {
          for (int i = 0; i < sets.length; i++) {
            if (i < last.sets.length) {
              sets[i]['weight']!.text = last.sets[i].weight.toString();
              sets[i]['reps']!.text = last.sets[i].reps.toString();
            }
          }
        }
      } else {
        setBS(() => previousSession = 'No previous session found.');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setBS) {
        final filtered = exerciseDatabase.where((e) =>
          e.name.toLowerCase().contains(search.toLowerCase()) ||
          e.primaryMuscle.toLowerCase().contains(search.toLowerCase())).toList();

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.95,
          builder: (_, sc) => SingleChildScrollView(
            controller: sc,
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Log Workout', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),

              // Custom toggle
              Row(children: [
                Checkbox(value: isCustom, onChanged: (v) => setBS(() { isCustom = v!; selectedEx = null; }),
                    activeColor: AppTheme.primaryColor),
                const Text('Custom exercise', style: TextStyle(color: AppTheme.textSecondary)),
              ]),

              if (isCustom) ...[
                TextField(controller: customNameCtrl, decoration: const InputDecoration(hintText: 'Exercise name')),
                const SizedBox(height: 8),
                // Type picker
                Row(children: ['Strength','Cardio','Bodyweight'].map((t) =>
                  Padding(padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(label: Text(t), selected: selectedType == t,
                        onSelected: (_) => setBS(() => selectedType = t)))).toList()),
              ] else ...[
                // Search
                TextField(
                  decoration: const InputDecoration(hintText: 'Search exercise or muscle...', prefixIcon: Icon(Icons.search)),
                  onChanged: (v) => setBS(() { search = v; selectedEx = null; }),
                ),
                const SizedBox(height: 8),
                ...filtered.take(15).map((ex) {
                  final isSelected = selectedEx?.id == ex.id;
                  return GestureDetector(
                    onTap: () {
                      setBS(() => selectedEx = isSelected ? null : ex);
                      if (!isSelected) loadPrevious(ex, setBS);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor.withAlpha(20) : AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(ex.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(10)),
                            child: Text(ex.type, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11)),
                          ),
                        ]),
                        Text('${ex.primaryMuscle}  •  ${ex.equipment}  •  ${ex.difficulty}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                        if (isSelected && ex.tips.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('💡 ${ex.tips}',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          ),
                      ]),
                    ),
                  );
                }),
              ],

              if (selectedEx != null || isCustom) ...[
                const SizedBox(height: 16),
                // Previous session
                if (previousSession.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(8)),
                    child: Text(previousSession, style: const TextStyle(color: AppTheme.accentColor, fontSize: 12)),
                  ),
                const SizedBox(height: 14),
                // Sets header
                Row(children: [
                  const Expanded(flex: 3, child: Text('Weight (kg)', style: TextStyle(color: AppTheme.textMuted, fontSize: 12))),
                  const SizedBox(width: 8),
                  const Expanded(flex: 2, child: Text('Reps', style: TextStyle(color: AppTheme.textMuted, fontSize: 12))),
                  const SizedBox(width: 8),
                  const Expanded(flex: 2, child: Text('1RM', style: TextStyle(color: AppTheme.textMuted, fontSize: 12))),
                  const SizedBox(width: 36),
                ]),
                ...sets.asMap().entries.map((e) {
                  final i = e.key;
                  final s = e.value;
                  final w = double.tryParse(s['weight']!.text) ?? 0;
                  final r = int.tryParse(s['reps']!.text) ?? 0;
                  final rm = r == 1 ? w : w * (1 + r / 30.0);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(children: [
                      Expanded(flex: 3, child: TextField(
                        controller: s['weight'],
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setBS(() {}),
                        decoration: InputDecoration(
                          hintText: '0',
                          prefixText: 'Set ${i + 1}: ',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      )),
                      const SizedBox(width: 8),
                      Expanded(flex: 2, child: TextField(
                        controller: s['reps'],
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setBS(() {}),
                        decoration: const InputDecoration(
                          hintText: '8', isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      )),
                      const SizedBox(width: 8),
                      Expanded(flex: 2, child: Text('${rm.toStringAsFixed(1)}kg',
                          style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.w600, fontSize: 12))),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppTheme.dangerColor, size: 20),
                        onPressed: sets.length > 1 ? () => setBS(() => sets.removeAt(i)) : null,
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      ),
                    ]),
                  );
                }),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => setBS(() => sets.add({'weight': TextEditingController(), 'reps': TextEditingController(text: '8')})),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Set'),
                ),
                // Rest timer buttons
                const SizedBox(height: 12),
                Row(children: [
                  const Text('Rest: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ...([60, 90, 120, 180]).map((s) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _startRestTimer(s);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                      ),
                      child: Text('${s}s', style: const TextStyle(fontSize: 12)),
                    ),
                  )),
                ]),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final exerciseName = isCustom
                          ? (customNameCtrl.text.trim().isEmpty ? 'Custom Exercise' : customNameCtrl.text.trim())
                          : selectedEx!.name;
                      final parsedSets = sets.map((s) {
                        final w = double.tryParse(s['weight']!.text) ?? 0;
                        final r = int.tryParse(s['reps']!.text) ?? 0;
                        return WorkoutSet(weight: w, reps: r);
                      }).where((s) => s.weight > 0 && s.reps > 0).toList();

                      if (parsedSets.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter at least one valid set.')));
                        return;
                      }

                      // Check PRs
                      final bestRM = parsedSets.map((s) => s.oneRepMax).reduce((a, b) => a > b ? a : b);
                      await DatabaseHelper.instance.checkAndSavePR(
                        exerciseName, parsedSets.last.weight, parsedSets.last.reps, bestRM, widget.activeDate);

                      // Check if this is a new PR
                      final prs = await DatabaseHelper.instance.getAllPRs();
                      final existingPR = prs[exerciseName] ?? 0;
                      bool isPRSet = bestRM >= existingPR && existingPR > 0 && bestRM > 0;

                      // Mark PR sets
                      if (isPRSet) {
                        for (final s in parsedSets) {
                          if (s.oneRepMax >= existingPR) s.isPR = true;
                        }
                      }

                      final workout = WorkoutLog(
                        date: widget.activeDate,
                        exerciseName: exerciseName,
                        exerciseType: isCustom ? selectedType : selectedEx!.type,
                        primaryMuscle: isCustom ? 'Custom' : selectedEx!.primaryMuscle,
                        sets: parsedSets,
                      );
                      await DatabaseHelper.instance.insertWorkout(workout);

                      if (isPRSet) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Row(children: [
                            const Text('🏆 NEW PR! '),
                            Text('${exerciseName} — ${bestRM.toStringAsFixed(1)}kg 1RM!',
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                          ]), backgroundColor: const Color(0xFF1C2A1C),
                          duration: const Duration(seconds: 4)));
                      }
                      Navigator.pop(ctx);
                      _loadData();
                    },
                    child: const Text('Save Workout'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ]),
          ),
        );
      }),
    );
  }

  void _startRestTimer(int seconds) {
    setState(() {
      _restTimerSeconds = seconds;
      _restTimerRunning = true;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_restTimerRunning) return false;
      setState(() => _restTimerSeconds--);
      if (_restTimerSeconds <= 0) {
        _restTimerRunning = false;
        return false;
      }
      return true;
    });
  }

  void _showAddSupplementSheet() {
    String name = 'Creatine';
    final amountCtrl = TextEditingController(text: '5');
    String unit = 'g';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Supplement'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            value: name,
            decoration: const InputDecoration(labelText: 'Supplement'),
            dropdownColor: AppTheme.bgCard,
            items: ['Pre-workout','Creatine','Whey Protein','Casein','BCAA','Vitamin D','Omega-3','Other']
                .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => name = v!,
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: amountCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'))),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: unit,
              dropdownColor: AppTheme.bgCard,
              items: ['g','mg','ml','scoops','tablets'].map((u) =>
                DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) => unit = v!,
            ),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.insertSupplement(SupplementLog(
                date: widget.activeDate, supplementName: name,
                amount: double.tryParse(amountCtrl.text) ?? 0, unit: unit,
              ));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name logged! 💊')));
            },
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }

  void _showLogWeightDialog() {
    final ctrl = TextEditingController(text: widget.profile.weight.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Body Weight'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Weight (kg)', suffixText: 'kg'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final w = double.tryParse(ctrl.text) ?? 0;
              if (w > 0) {
                await DatabaseHelper.instance.insertWeight(WeightLog(
                  date: widget.activeDate, weight: w));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Weight ${w}kg logged! ⚖️')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _todayStr() {
    final n = DateTime.now();
    return _dateStr(n);
  }
}
