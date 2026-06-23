class MealLog {
  int? id;
  String date;          // YYYY-MM-DD
  String category;      // Breakfast|Lunch|Dinner|Snack
  String foodName;
  String foodCategory;  // Indian|Global|Custom
  double portionGrams;
  double calories;
  double protein;
  double carbs;
  double fat;
  double fiber;
  double sugar;
  double sodium;
  String servingUnit;
  DateTime timestamp;
  bool isFavorite;

  MealLog({
    this.id,
    required this.date,
    required this.category,
    required this.foodName,
    required this.foodCategory,
    required this.portionGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    this.servingUnit = '100g',
    DateTime? timestamp,
    this.isFavorite = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'category': category,
    'foodName': foodName,
    'foodCategory': foodCategory,
    'portionGrams': portionGrams,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'fiber': fiber,
    'sugar': sugar,
    'sodium': sodium,
    'servingUnit': servingUnit,
    'timestamp': timestamp.toIso8601String(),
    'isFavorite': isFavorite ? 1 : 0,
  };

  factory MealLog.fromMap(Map<String, dynamic> map) => MealLog(
    id: map['id'],
    date: map['date'],
    category: map['category'],
    foodName: map['foodName'],
    foodCategory: map['foodCategory'] ?? 'Custom',
    portionGrams: (map['portionGrams'] as num).toDouble(),
    calories: (map['calories'] as num).toDouble(),
    protein: (map['protein'] as num).toDouble(),
    carbs: (map['carbs'] as num).toDouble(),
    fat: (map['fat'] as num).toDouble(),
    fiber: (map['fiber'] as num?)?.toDouble() ?? 0,
    sugar: (map['sugar'] as num?)?.toDouble() ?? 0,
    sodium: (map['sodium'] as num?)?.toDouble() ?? 0,
    servingUnit: map['servingUnit'] ?? '100g',
    timestamp: DateTime.parse(map['timestamp']),
    isFavorite: (map['isFavorite'] ?? 0) == 1,
  );

  Map<String, dynamic> toJson() => toMap();
  factory MealLog.fromJson(Map<String, dynamic> json) => MealLog.fromMap(json);
}

class DailySummary {
  final String date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int waterMl;
  final int steps;

  DailySummary({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.waterMl,
    required this.steps,
  });
}
