class UserProfile {
  int? id;
  String name;
  double weight;        // in kg
  double height;        // in cm
  int age;
  String gender;        // 'male' | 'female'
  String goal;          // 'lose' | 'maintain' | 'build'
  double targetWeight;
  String units;         // 'metric' | 'imperial'
  int calorieBudget;
  int proteinGoal;      // grams
  int carbsGoal;        // grams
  int fatGoal;          // grams
  int waterGoal;        // ml
  int stepGoal;
  String pin;
  DateTime createdAt;
  DateTime updatedAt;

  UserProfile({
    this.id,
    required this.name,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.goal,
    required this.targetWeight,
    required this.units,
    required this.calorieBudget,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    this.waterGoal = 2500,
    this.stepGoal = 8000,
    this.pin = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Mifflin-St Jeor BMR
  double get bmr {
    if (gender == 'male') {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  // TDEE with moderate activity (1.55)
  double get tdee => bmr * 1.55;

  static int calculateCalorieBudget(String goal, double tdee) {
    switch (goal) {
      case 'lose': return (tdee - 500).round();
      case 'build': return (tdee + 300).round();
      default: return tdee.round();
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'weight': weight,
    'height': height,
    'age': age,
    'gender': gender,
    'goal': goal,
    'targetWeight': targetWeight,
    'units': units,
    'calorieBudget': calorieBudget,
    'proteinGoal': proteinGoal,
    'carbsGoal': carbsGoal,
    'fatGoal': fatGoal,
    'waterGoal': waterGoal,
    'stepGoal': stepGoal,
    'pin': pin,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    id: map['id'],
    name: map['name'],
    weight: (map['weight'] as num).toDouble(),
    height: (map['height'] as num).toDouble(),
    age: map['age'],
    gender: map['gender'],
    goal: map['goal'],
    targetWeight: (map['targetWeight'] as num).toDouble(),
    units: map['units'] ?? 'metric',
    calorieBudget: map['calorieBudget'],
    proteinGoal: map['proteinGoal'],
    carbsGoal: map['carbsGoal'],
    fatGoal: map['fatGoal'],
    waterGoal: map['waterGoal'] ?? 2500,
    stepGoal: map['stepGoal'] ?? 8000,
    pin: map['pin'] ?? '',
    createdAt: DateTime.parse(map['createdAt']),
    updatedAt: DateTime.parse(map['updatedAt']),
  );

  UserProfile copyWith({
    String? name, double? weight, double? height, int? age,
    String? gender, String? goal, double? targetWeight, String? units,
    int? calorieBudget, int? proteinGoal, int? carbsGoal, int? fatGoal,
    int? waterGoal, int? stepGoal, String? pin,
  }) => UserProfile(
    id: id,
    name: name ?? this.name,
    weight: weight ?? this.weight,
    height: height ?? this.height,
    age: age ?? this.age,
    gender: gender ?? this.gender,
    goal: goal ?? this.goal,
    targetWeight: targetWeight ?? this.targetWeight,
    units: units ?? this.units,
    calorieBudget: calorieBudget ?? this.calorieBudget,
    proteinGoal: proteinGoal ?? this.proteinGoal,
    carbsGoal: carbsGoal ?? this.carbsGoal,
    fatGoal: fatGoal ?? this.fatGoal,
    waterGoal: waterGoal ?? this.waterGoal,
    stepGoal: stepGoal ?? this.stepGoal,
    pin: pin ?? this.pin,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}
