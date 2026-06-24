import 'dart:convert';

class WorkoutSet {
  double weight;  // kg
  int reps;
  bool isWarmup;
  bool isPR;
  String? note;

  WorkoutSet({
    required this.weight,
    required this.reps,
    this.isWarmup = false,
    this.isPR = false,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'reps': reps,
    'isWarmup': isWarmup,
    'isPR': isPR,
    'note': note,
  };

  factory WorkoutSet.fromJson(Map<String, dynamic> j) => WorkoutSet(
    weight: (j['weight'] as num).toDouble(),
    reps: j['reps'],
    isWarmup: j['isWarmup'] ?? false,
    isPR: j['isPR'] ?? false,
    note: j['note'],
  );

  // Epley 1RM formula
  double get oneRepMax => reps == 1 ? weight : weight * (1 + reps / 30.0);
  double get volume => weight * reps;
}

class WorkoutLog {
  int? id;
  String date;
  String exerciseName;
  String exerciseType;    // Strength|Cardio|Bodyweight
  String primaryMuscle;
  List<WorkoutSet> sets;
  int? durationMinutes;   // for cardio
  double? distanceKm;     // for cardio
  String? notes;
  bool isTemplate;
  String? templateName;
  DateTime timestamp;

  WorkoutLog({
    this.id,
    required this.date,
    required this.exerciseName,
    required this.exerciseType,
    required this.primaryMuscle,
    required this.sets,
    this.durationMinutes,
    this.distanceKm,
    this.notes,
    this.isTemplate = false,
    this.templateName,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  double get totalVolume => sets.fold(0, (sum, s) => sum + s.volume);
  double get maxWeight => sets.isEmpty ? 0 : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
  double get bestOneRM => sets.isEmpty ? 0 : sets.map((s) => s.oneRepMax).reduce((a, b) => a > b ? a : b);
  int get totalReps => sets.fold(0, (sum, s) => sum + s.reps);
  bool get hasPR => sets.any((s) => s.isPR);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'exerciseName': exerciseName,
      'exerciseType': exerciseType,
      'primaryMuscle': primaryMuscle,
      'sets': json.encode(sets.map((s) => s.toJson()).toList()),
      'durationMinutes': durationMinutes,
      'distanceKm': distanceKm,
      'notes': notes,
      'isTemplate': isTemplate ? 1 : 0,
      'templateName': templateName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WorkoutLog.fromMap(Map<String, dynamic> map) {
    List<WorkoutSet> parsedSets = [];
    try {
      // Parse the sets JSON string
      final setsStr = map['sets'] as String? ?? '[]';
      // Use a simpler parsing approach
      parsedSets = _parseSets(setsStr);
    } catch (_) {
      parsedSets = [];
    }
    return WorkoutLog(
      id: map['id'],
      date: map['date'],
      exerciseName: map['exerciseName'],
      exerciseType: map['exerciseType'] ?? 'Strength',
      primaryMuscle: map['primaryMuscle'] ?? '',
      sets: parsedSets,
      durationMinutes: map['durationMinutes'],
      distanceKm: (map['distanceKm'] as num?)?.toDouble(),
      notes: map['notes'],
      isTemplate: (map['isTemplate'] ?? 0) == 1,
      templateName: map['templateName'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  static List<WorkoutSet> _parseSets(String setsStr) {
    if (setsStr.isEmpty || setsStr == '[]') return [];
    try {
      final decoded = json.decode(setsStr) as List<dynamic>;
      return decoded.map((item) {
        final m = item as Map<String, dynamic>;
        return WorkoutSet(
          weight: (m['weight'] as num?)?.toDouble() ?? 0,
          reps: (m['reps'] as num?)?.toInt() ?? 0,
          isWarmup: m['isWarmup'] as bool? ?? false,
          isPR: m['isPR'] as bool? ?? false,
          note: m['note'] as String?,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> toJson() => toMap();
  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog.fromMap(json);
}

class WorkoutTemplate {
  int? id;
  String name;
  String description;
  List<Map<String, dynamic>> exercises;  // list of exercise stubs
  DateTime createdAt;

  WorkoutTemplate({
    this.id,
    required this.name,
    required this.description,
    required this.exercises,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'exercises': exercises.toString(),
    'createdAt': createdAt.toIso8601String(),
  };
}
