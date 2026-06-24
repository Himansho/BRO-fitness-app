import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_profile.dart';
import '../models/meal_log.dart';
import '../models/workout_log.dart';
import '../models/photo_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  static const int _version = 1;
  static const String _dbName = 'bro_fitness.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final docDir = await getApplicationDocumentsDirectory();
    final path = join(docDir.path, _dbName);
    return await openDatabase(path, version: _version, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        goal TEXT NOT NULL,
        targetWeight REAL NOT NULL,
        units TEXT NOT NULL DEFAULT 'metric',
        calorieBudget INTEGER NOT NULL,
        proteinGoal INTEGER NOT NULL,
        carbsGoal INTEGER NOT NULL,
        fatGoal INTEGER NOT NULL,
        waterGoal INTEGER NOT NULL DEFAULT 2500,
        stepGoal INTEGER NOT NULL DEFAULT 8000,
        pin TEXT NOT NULL DEFAULT '',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE meal_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        foodName TEXT NOT NULL,
        foodCategory TEXT NOT NULL DEFAULT 'Custom',
        portionGrams REAL NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        fiber REAL NOT NULL DEFAULT 0,
        sugar REAL NOT NULL DEFAULT 0,
        sodium REAL NOT NULL DEFAULT 0,
        servingUnit TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        exerciseName TEXT NOT NULL,
        exerciseType TEXT NOT NULL,
        primaryMuscle TEXT NOT NULL,
        sets TEXT NOT NULL,
        durationMinutes INTEGER,
        distanceKm REAL,
        notes TEXT,
        isTemplate INTEGER NOT NULL DEFAULT 0,
        templateName TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE photo_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        filePath TEXT NOT NULL,
        pose TEXT NOT NULL DEFAULT 'Front',
        weight REAL,
        bodyFat REAL,
        notes TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE body_measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        chestCm REAL,
        waistCm REAL,
        hipsCm REAL,
        leftArmCm REAL,
        rightArmCm REAL,
        leftThighCm REAL,
        rightThighCm REAL,
        shouldersCm REAL,
        neckCm REAL,
        calfCm REAL,
        bodyFatPercent REAL,
        notes TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE weight_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        weight REAL NOT NULL,
        notes TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE water_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        totalMl INTEGER NOT NULL DEFAULT 0,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE supplement_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        supplementName TEXT NOT NULL,
        amount REAL NOT NULL,
        unit TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE personal_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exerciseName TEXT NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        oneRepMax REAL NOT NULL,
        date TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        isEnabled INTEGER NOT NULL DEFAULT 1,
        type TEXT NOT NULL DEFAULT 'custom'
      )
    ''');
  }

  // ─────────────────── USER PROFILE ───────────────────
  Future<UserProfile?> getProfile() async {
    final db = await database;
    final rows = await db.query('user_profile', limit: 1);
    if (rows.isEmpty) return null;
    return UserProfile.fromMap(rows.first);
  }

  Future<int> saveProfile(UserProfile profile) async {
    final db = await database;
    if (profile.id == null) {
      return await db.insert('user_profile', profile.toMap());
    } else {
      await db.update('user_profile', profile.toMap(), where: 'id = ?', whereArgs: [profile.id]);
      return profile.id!;
    }
  }

  // ─────────────────── MEAL LOGS ───────────────────
  Future<int> insertMeal(MealLog meal) async {
    final db = await database;
    return await db.insert('meal_logs', meal.toMap());
  }

  Future<List<MealLog>> getMealsForDate(String date) async {
    final db = await database;
    final rows = await db.query('meal_logs', where: 'date = ?', whereArgs: [date], orderBy: 'timestamp ASC');
    return rows.map((r) => MealLog.fromMap(r)).toList();
  }

  Future<List<MealLog>> getAllMeals() async {
    final db = await database;
    final rows = await db.query('meal_logs', orderBy: 'timestamp DESC');
    return rows.map((r) => MealLog.fromMap(r)).toList();
  }

  Future<void> deleteMeal(int id) async {
    final db = await database;
    await db.delete('meal_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MealLog>> getRecentMeals({int limit = 10}) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT * FROM meal_logs 
      GROUP BY foodName 
      ORDER BY MAX(timestamp) DESC 
      LIMIT ?
    ''', [limit]);
    return rows.map((r) => MealLog.fromMap(r)).toList();
  }

  // ─────────────────── WORKOUT LOGS ───────────────────
  Future<int> insertWorkout(WorkoutLog workout) async {
    final db = await database;
    return await db.insert('workout_logs', workout.toMap());
  }

  Future<List<WorkoutLog>> getWorkoutsForDate(String date) async {
    final db = await database;
    final rows = await db.query('workout_logs', where: 'date = ?', whereArgs: [date], orderBy: 'timestamp ASC');
    return rows.map((r) => WorkoutLog.fromMap(r)).toList();
  }

  Future<List<WorkoutLog>> getAllWorkouts() async {
    final db = await database;
    final rows = await db.query('workout_logs', orderBy: 'timestamp DESC');
    return rows.map((r) => WorkoutLog.fromMap(r)).toList();
  }

  Future<void> deleteWorkout(int id) async {
    final db = await database;
    await db.delete('workout_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WorkoutLog>> getWorkoutHistoryForExercise(String exerciseName, {int limit = 10}) async {
    final db = await database;
    final rows = await db.query('workout_logs',
        where: 'exerciseName = ?',
        whereArgs: [exerciseName],
        orderBy: 'timestamp DESC',
        limit: limit);
    return rows.map((r) => WorkoutLog.fromMap(r)).toList();
  }

  // ─────────────────── PHOTO ENTRIES ───────────────────
  Future<int> insertPhoto(PhotoEntry photo) async {
    final db = await database;
    return await db.insert('photo_entries', photo.toMap());
  }

  Future<List<PhotoEntry>> getAllPhotos() async {
    final db = await database;
    final rows = await db.query('photo_entries', orderBy: 'timestamp DESC');
    return rows.map((r) => PhotoEntry.fromMap(r)).toList();
  }

  Future<void> deletePhoto(int id) async {
    final db = await database;
    await db.delete('photo_entries', where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────────── BODY MEASUREMENTS ───────────────────
  Future<int> insertMeasurement(BodyMeasurement m) async {
    final db = await database;
    return await db.insert('body_measurements', m.toMap());
  }

  Future<List<BodyMeasurement>> getAllMeasurements() async {
    final db = await database;
    final rows = await db.query('body_measurements', orderBy: 'timestamp DESC');
    return rows.map((r) => BodyMeasurement.fromMap(r)).toList();
  }

  Future<BodyMeasurement?> getLatestMeasurement() async {
    final db = await database;
    final rows = await db.query('body_measurements', orderBy: 'timestamp DESC', limit: 1);
    if (rows.isEmpty) return null;
    return BodyMeasurement.fromMap(rows.first);
  }

  // ─────────────────── WEIGHT LOGS ───────────────────
  Future<int> insertWeight(WeightLog w) async {
    final db = await database;
    return await db.insert('weight_logs', w.toMap());
  }

  Future<List<WeightLog>> getWeightLogs({int limit = 30}) async {
    final db = await database;
    final rows = await db.query('weight_logs', orderBy: 'timestamp DESC', limit: limit);
    return rows.map((r) => WeightLog.fromMap(r)).toList();
  }

  Future<WeightLog?> getWeightForDate(String date) async {
    final db = await database;
    final rows = await db.query('weight_logs', where: 'date = ?', whereArgs: [date]);
    if (rows.isEmpty) return null;
    return WeightLog.fromMap(rows.first);
  }

  // ─────────────────── WATER LOGS ───────────────────
  Future<int> getWaterForDate(String date) async {
    final db = await database;
    final rows = await db.query('water_logs', where: 'date = ?', whereArgs: [date]);
    if (rows.isEmpty) return 0;
    return rows.first['totalMl'] as int;
  }

  Future<void> setWaterForDate(String date, int totalMl) async {
    final db = await database;
    await db.insert('water_logs',
      {'date': date, 'totalMl': totalMl, 'updatedAt': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─────────────────── SUPPLEMENT LOGS ───────────────────
  Future<int> insertSupplement(SupplementLog s) async {
    final db = await database;
    return await db.insert('supplement_logs', s.toMap());
  }

  Future<List<SupplementLog>> getSupplementsForDate(String date) async {
    final db = await database;
    final rows = await db.query('supplement_logs', where: 'date = ?', whereArgs: [date]);
    return rows.map((r) => SupplementLog.fromMap(r)).toList();
  }

  Future<void> deleteSupplement(int id) async {
    final db = await database;
    await db.delete('supplement_logs', where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────────── PERSONAL RECORDS ───────────────────
  Future<void> checkAndSavePR(String exerciseName, double weight, int reps, double oneRM, String date) async {
    final db = await database;
    final existing = await db.query('personal_records',
        where: 'exerciseName = ?', whereArgs: [exerciseName], orderBy: 'oneRepMax DESC', limit: 1);
    final currentBest = existing.isEmpty ? 0.0 : (existing.first['oneRepMax'] as num).toDouble();
    if (oneRM > currentBest) {
      await db.insert('personal_records', {
        'exerciseName': exerciseName,
        'weight': weight,
        'reps': reps,
        'oneRepMax': oneRM,
        'date': date,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<Map<String, double>> getAllPRs() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT exerciseName, MAX(oneRepMax) as best
      FROM personal_records
      GROUP BY exerciseName
      ORDER BY best DESC
    ''');
    final result = <String, double>{};
    for (final r in rows) {
      result[r['exerciseName'] as String] = (r['best'] as num).toDouble();
    }
    return result;
  }

  // ─────────────────── ANALYTICS ───────────────────
  Future<List<Map<String, dynamic>>> getLast7DaysCalories() async {
    final today = DateTime.now();

    final result = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final dateStr = _dateStr(d);
      final meals = await getMealsForDate(dateStr);
      final totalCal = meals.fold<double>(0, (sum, m) => sum + m.calories);
      final totalProtein = meals.fold<double>(0, (sum, m) => sum + m.protein);
      result.add({'date': dateStr, 'calories': totalCal, 'protein': totalProtein});
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getLast30DaysWeight() async {
    final db = await database;
    final rows = await db.query('weight_logs', orderBy: 'timestamp DESC', limit: 30);
    return rows.map((r) => {'date': r['date'], 'weight': r['weight']}).toList().reversed.toList();
  }

  Future<int> getWorkoutStreakDays() async {
    final db = await database;
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final d = today.subtract(Duration(days: i));
      final dateStr = _dateStr(d);
      final rows = await db.query('workout_logs', where: 'date = ?', whereArgs: [dateStr], limit: 1);
      if (rows.isNotEmpty) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  String _dateStr(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ─────────────────── BACKUP / RESTORE ───────────────────
  Future<Map<String, dynamic>> exportAllData() async {
    final db = await database;
    return {
      'meals': (await db.query('meal_logs')).toList(),
      'workouts': (await db.query('workout_logs')).toList(),
      'photos': (await db.query('photo_entries')).toList(),
      'measurements': (await db.query('body_measurements')).toList(),
      'weights': (await db.query('weight_logs')).toList(),
      'water': (await db.query('water_logs')).toList(),
      'supplements': (await db.query('supplement_logs')).toList(),
      'prs': (await db.query('personal_records')).toList(),
      'profile': (await db.query('user_profile')).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': _version,
    };
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    final db = await database;
    await db.transaction((txn) async {
      // Clear existing
      for (final table in ['meal_logs', 'workout_logs', 'photo_entries',
          'body_measurements', 'weight_logs', 'water_logs',
          'supplement_logs', 'personal_records']) {
        await txn.delete(table);
      }
      // Re-insert
      Future<void> insertList(String table, List list) async {
        for (final row in list) {
          await txn.insert(table, Map<String, dynamic>.from(row));
        }
      }
      await insertList('meal_logs', data['meals'] ?? []);
      await insertList('workout_logs', data['workouts'] ?? []);
      await insertList('photo_entries', data['photos'] ?? []);
      await insertList('body_measurements', data['measurements'] ?? []);
      await insertList('weight_logs', data['weights'] ?? []);
      await insertList('water_logs', data['water'] ?? []);
      await insertList('supplement_logs', data['supplements'] ?? []);
      await insertList('personal_records', data['prs'] ?? []);
    });
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
