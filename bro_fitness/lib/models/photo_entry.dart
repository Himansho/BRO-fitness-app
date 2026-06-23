class PhotoEntry {
  int? id;
  String date;          // YYYY-MM-DD
  String filePath;      // local path to encrypted/stored image
  String pose;          // Front|Side|Back|Other
  double? weight;       // optional weight at time of photo
  double? bodyFat;      // optional body fat %
  String? notes;
  DateTime timestamp;

  PhotoEntry({
    this.id,
    required this.date,
    required this.filePath,
    this.pose = 'Front',
    this.weight,
    this.bodyFat,
    this.notes,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'filePath': filePath,
    'pose': pose,
    'weight': weight,
    'bodyFat': bodyFat,
    'notes': notes,
    'timestamp': timestamp.toIso8601String(),
  };

  factory PhotoEntry.fromMap(Map<String, dynamic> map) => PhotoEntry(
    id: map['id'],
    date: map['date'],
    filePath: map['filePath'],
    pose: map['pose'] ?? 'Front',
    weight: (map['weight'] as num?)?.toDouble(),
    bodyFat: (map['bodyFat'] as num?)?.toDouble(),
    notes: map['notes'],
    timestamp: DateTime.parse(map['timestamp']),
  );

  Map<String, dynamic> toJson() => toMap();
  factory PhotoEntry.fromJson(Map<String, dynamic> json) => PhotoEntry.fromMap(json);
}

class BodyMeasurement {
  int? id;
  String date;
  double? chestCm;
  double? waistCm;
  double? hipsCm;
  double? leftArmCm;
  double? rightArmCm;
  double? leftThighCm;
  double? rightThighCm;
  double? shouldersCm;
  double? neckCm;
  double? calfCm;
  double? bodyFatPercent;
  String? notes;
  DateTime timestamp;

  BodyMeasurement({
    this.id,
    required this.date,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
    this.leftArmCm,
    this.rightArmCm,
    this.leftThighCm,
    this.rightThighCm,
    this.shouldersCm,
    this.neckCm,
    this.calfCm,
    this.bodyFatPercent,
    this.notes,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'chestCm': chestCm,
    'waistCm': waistCm,
    'hipsCm': hipsCm,
    'leftArmCm': leftArmCm,
    'rightArmCm': rightArmCm,
    'leftThighCm': leftThighCm,
    'rightThighCm': rightThighCm,
    'shouldersCm': shouldersCm,
    'neckCm': neckCm,
    'calfCm': calfCm,
    'bodyFatPercent': bodyFatPercent,
    'notes': notes,
    'timestamp': timestamp.toIso8601String(),
  };

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) => BodyMeasurement(
    id: map['id'],
    date: map['date'],
    chestCm: (map['chestCm'] as num?)?.toDouble(),
    waistCm: (map['waistCm'] as num?)?.toDouble(),
    hipsCm: (map['hipsCm'] as num?)?.toDouble(),
    leftArmCm: (map['leftArmCm'] as num?)?.toDouble(),
    rightArmCm: (map['rightArmCm'] as num?)?.toDouble(),
    leftThighCm: (map['leftThighCm'] as num?)?.toDouble(),
    rightThighCm: (map['rightThighCm'] as num?)?.toDouble(),
    shouldersCm: (map['shouldersCm'] as num?)?.toDouble(),
    neckCm: (map['neckCm'] as num?)?.toDouble(),
    calfCm: (map['calfCm'] as num?)?.toDouble(),
    bodyFatPercent: (map['bodyFatPercent'] as num?)?.toDouble(),
    notes: map['notes'],
    timestamp: DateTime.parse(map['timestamp']),
  );

  Map<String, dynamic> toJson() => toMap();
  factory BodyMeasurement.fromJson(Map<String, dynamic> json) => BodyMeasurement.fromMap(json);
}

class WeightLog {
  int? id;
  String date;
  double weight;    // kg
  String? notes;
  DateTime timestamp;

  WeightLog({
    this.id,
    required this.date,
    required this.weight,
    this.notes,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'weight': weight,
    'notes': notes,
    'timestamp': timestamp.toIso8601String(),
  };

  factory WeightLog.fromMap(Map<String, dynamic> map) => WeightLog(
    id: map['id'],
    date: map['date'],
    weight: (map['weight'] as num).toDouble(),
    notes: map['notes'],
    timestamp: DateTime.parse(map['timestamp']),
  );

  Map<String, dynamic> toJson() => toMap();
  factory WeightLog.fromJson(Map<String, dynamic> json) => WeightLog.fromMap(json);
}

class WaterLog {
  int? id;
  String date;
  int totalMl;
  DateTime updatedAt;

  WaterLog({
    this.id,
    required this.date,
    required this.totalMl,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'totalMl': totalMl,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory WaterLog.fromMap(Map<String, dynamic> map) => WaterLog(
    id: map['id'],
    date: map['date'],
    totalMl: map['totalMl'],
    updatedAt: DateTime.parse(map['updatedAt']),
  );

  Map<String, dynamic> toJson() => toMap();
  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog.fromMap(json);
}

class SupplementLog {
  int? id;
  String date;
  String supplementName;  // Pre-workout|Creatine|Protein|Vitamin|Other
  double amount;
  String unit;            // g|mg|ml|scoops
  DateTime timestamp;
  String? notes;

  SupplementLog({
    this.id,
    required this.date,
    required this.supplementName,
    required this.amount,
    required this.unit,
    DateTime? timestamp,
    this.notes,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'supplementName': supplementName,
    'amount': amount,
    'unit': unit,
    'timestamp': timestamp.toIso8601String(),
    'notes': notes,
  };

  factory SupplementLog.fromMap(Map<String, dynamic> map) => SupplementLog(
    id: map['id'],
    date: map['date'],
    supplementName: map['supplementName'],
    amount: (map['amount'] as num).toDouble(),
    unit: map['unit'],
    timestamp: DateTime.parse(map['timestamp']),
    notes: map['notes'],
  );
}
