class ExerciseItem {
  final String id;
  final String name;
  final String type;          // Strength|Cardio|Bodyweight|Stretching
  final String primaryMuscle;
  final String secondaryMuscles;
  final String equipment;     // Barbell|Dumbbell|Machine|Bodyweight|Cable|Band
  final String difficulty;    // Beginner|Intermediate|Advanced
  final String tips;

  const ExerciseItem({
    required this.id,
    required this.name,
    required this.type,
    required this.primaryMuscle,
    this.secondaryMuscles = '',
    required this.equipment,
    this.difficulty = 'Intermediate',
    this.tips = '',
  });
}

const List<ExerciseItem> exerciseDatabase = [
  // ──────────────────────────── CHEST ────────────────────────────
  ExerciseItem(
    id: 'e-001', name: 'Bench Press (Barbell)', type: 'Strength',
    primaryMuscle: 'Chest', secondaryMuscles: 'Triceps, Front Delts',
    equipment: 'Barbell', difficulty: 'Intermediate',
    tips: 'Keep shoulder blades retracted. Lower bar to mid-chest. Drive through heels.',
  ),
  ExerciseItem(
    id: 'e-002', name: 'Incline Dumbbell Press', type: 'Strength',
    primaryMuscle: 'Upper Chest', secondaryMuscles: 'Triceps, Shoulders',
    equipment: 'Dumbbell', difficulty: 'Intermediate',
    tips: 'Set bench to 30-45°. Full range of motion is key.',
  ),
  ExerciseItem(
    id: 'e-003', name: 'Decline Bench Press', type: 'Strength',
    primaryMuscle: 'Lower Chest', secondaryMuscles: 'Triceps',
    equipment: 'Barbell', difficulty: 'Intermediate',
    tips: 'Angle puts more emphasis on lower pec. Keep tight arch.',
  ),
  ExerciseItem(
    id: 'e-004', name: 'Dumbbell Flyes', type: 'Strength',
    primaryMuscle: 'Chest', secondaryMuscles: 'Front Delts',
    equipment: 'Dumbbell', difficulty: 'Beginner',
    tips: 'Slight bend in elbows throughout. Squeeze chest at top.',
  ),
  ExerciseItem(
    id: 'e-005', name: 'Cable Crossover', type: 'Strength',
    primaryMuscle: 'Chest', secondaryMuscles: 'Front Delts',
    equipment: 'Cable', difficulty: 'Intermediate',
    tips: 'Keep constant tension. Cross hands at bottom.',
  ),
  ExerciseItem(
    id: 'e-006', name: 'Push-Up', type: 'Bodyweight',
    primaryMuscle: 'Chest', secondaryMuscles: 'Triceps, Core',
    equipment: 'Bodyweight', difficulty: 'Beginner',
    tips: 'Core tight, straight body line. Touch chest to floor.',
  ),

  // ──────────────────────────── BACK ────────────────────────────
  ExerciseItem(
    id: 'e-011', name: 'Deadlift (Barbell)', type: 'Strength',
    primaryMuscle: 'Hamstrings & Lower Back', secondaryMuscles: 'Glutes, Traps, Lats',
    equipment: 'Barbell', difficulty: 'Advanced',
    tips: 'Hip hinge, neutral spine. Push floor away. Lock out at top.',
  ),
  ExerciseItem(
    id: 'e-012', name: 'Barbell Row (Bent-Over)', type: 'Strength',
    primaryMuscle: 'Upper Back', secondaryMuscles: 'Biceps, Lats, Rear Delts',
    equipment: 'Barbell', difficulty: 'Intermediate',
    tips: 'Hinge at hips ~45°. Pull to lower stomach. Squeeze scapula.',
  ),
  ExerciseItem(
    id: 'e-013', name: 'Lat Pulldown (Wide Grip)', type: 'Strength',
    primaryMuscle: 'Lats', secondaryMuscles: 'Biceps, Teres Major',
    equipment: 'Cable', difficulty: 'Beginner',
    tips: 'Pull to upper chest. Lean back slightly. Squeeze lats at bottom.',
  ),
  ExerciseItem(
    id: 'e-014', name: 'Pull-Up (Overhand)', type: 'Bodyweight',
    primaryMuscle: 'Lats', secondaryMuscles: 'Biceps, Core',
    equipment: 'Bodyweight', difficulty: 'Intermediate',
    tips: 'Dead hang start. Drive elbows down. Clear chin over bar.',
  ),
  ExerciseItem(
    id: 'e-015', name: 'Chin-Up (Underhand)', type: 'Bodyweight',
    primaryMuscle: 'Lats & Biceps', secondaryMuscles: 'Core',
    equipment: 'Bodyweight', difficulty: 'Intermediate',
    tips: 'Supinated grip = more bicep activation than pull-up.',
  ),
  ExerciseItem(
    id: 'e-016', name: 'Seated Cable Row', type: 'Strength',
    primaryMuscle: 'Mid Back', secondaryMuscles: 'Biceps, Rear Delts',
    equipment: 'Cable', difficulty: 'Beginner',
    tips: 'Full stretch at start. Row to navel. Pause and squeeze.',
  ),
  ExerciseItem(
    id: 'e-017', name: 'Dumbbell Row (Single Arm)', type: 'Strength',
    primaryMuscle: 'Lats', secondaryMuscles: 'Biceps, Rhomboids',
    equipment: 'Dumbbell', difficulty: 'Beginner',
    tips: 'Support on bench. Row to hip. Don\'t rotate torso excessively.',
  ),

  // ──────────────────────────── SHOULDERS ────────────────────────────
  ExerciseItem(
    id: 'e-021', name: 'Overhead Press (Barbell)', type: 'Strength',
    primaryMuscle: 'Shoulders (All Heads)', secondaryMuscles: 'Triceps, Upper Traps',
    equipment: 'Barbell', difficulty: 'Intermediate',
    tips: 'Brace core. Press straight up. Don\'t lean back excessively.',
  ),
  ExerciseItem(
    id: 'e-022', name: 'Seated Dumbbell Press', type: 'Strength',
    primaryMuscle: 'Shoulders', secondaryMuscles: 'Triceps',
    equipment: 'Dumbbell', difficulty: 'Beginner',
    tips: 'Keep dumbbells at ear level. Press overhead without locking elbows.',
  ),
  ExerciseItem(
    id: 'e-023', name: 'Lateral Raise (Dumbbell)', type: 'Strength',
    primaryMuscle: 'Lateral Delts', secondaryMuscles: '',
    equipment: 'Dumbbell', difficulty: 'Beginner',
    tips: 'Slight bend in elbow. Raise to shoulder height. Control the descent.',
  ),
  ExerciseItem(
    id: 'e-024', name: 'Front Raise (Dumbbell)', type: 'Strength',
    primaryMuscle: 'Front Delts', secondaryMuscles: '',
    equipment: 'Dumbbell', difficulty: 'Beginner',
    tips: 'Thumbs up grip. Raise to eye level. Avoid swinging.',
  ),
  ExerciseItem(
    id: 'e-025', name: 'Face Pull (Cable)', type: 'Strength',
    primaryMuscle: 'Rear Delts', secondaryMuscles: 'External Rotators, Rhomboids',
    equipment: 'Cable', difficulty: 'Beginner',
    tips: 'Pull to face, hands to ears. Great for shoulder health.',
  ),

  // ──────────────────────────── ARMS ────────────────────────────
  ExerciseItem(
    id: 'e-031', name: 'Barbell Bicep Curl', type: 'Strength',
    primaryMuscle: 'Biceps', secondaryMuscles: 'Forearms',
    equipment: 'Barbell', difficulty: 'Beginner',
    tips: 'Elbows at sides. Full extension at bottom. Squeeze at top.',
  ),
  ExerciseItem(
    id: 'e-032', name: 'Hammer Curl (Dumbbell)', type: 'Strength',
    primaryMuscle: 'Brachialis & Biceps', secondaryMuscles: 'Forearms',
    equipment: 'Dumbbell', difficulty: 'Beginner',
    tips: 'Neutral grip (like a hammer). Hits brachialis for arm thickness.',
  ),
  ExerciseItem(
    id: 'e-033', name: 'Preacher Curl (Machine/Barbell)', type: 'Strength',
    primaryMuscle: 'Biceps (Long Head)', secondaryMuscles: '',
    equipment: 'Machine', difficulty: 'Beginner',
    tips: 'Isolates biceps. Full stretch at bottom. Don\'t cheat with momentum.',
  ),
  ExerciseItem(
    id: 'e-034', name: 'Tricep Pushdown (Cable)', type: 'Strength',
    primaryMuscle: 'Triceps', secondaryMuscles: '',
    equipment: 'Cable', difficulty: 'Beginner',
    tips: 'Elbows at sides. Lock out at bottom. Control the return.',
  ),
  ExerciseItem(
    id: 'e-035', name: 'Skull Crusher (EZ Bar)', type: 'Strength',
    primaryMuscle: 'Triceps (Long Head)', secondaryMuscles: '',
    equipment: 'Barbell', difficulty: 'Intermediate',
    tips: 'Lower to forehead. Keep upper arms vertical. Great for mass.',
  ),
  ExerciseItem(
    id: 'e-036', name: 'Tricep Dips (Bodyweight)', type: 'Bodyweight',
    primaryMuscle: 'Triceps', secondaryMuscles: 'Chest, Shoulders',
    equipment: 'Bodyweight', difficulty: 'Intermediate',
    tips: 'Upright torso for triceps focus. Lean forward for more chest.',
  ),

  // ──────────────────────────── LEGS ────────────────────────────
  ExerciseItem(
    id: 'e-041', name: 'Squat (Barbell)', type: 'Strength',
    primaryMuscle: 'Quads', secondaryMuscles: 'Glutes, Hamstrings, Core',
    equipment: 'Barbell', difficulty: 'Intermediate',
    tips: 'Chest up, brace core. Break parallel. Drive knees out.',
  ),
  ExerciseItem(
    id: 'e-042', name: 'Leg Press', type: 'Strength',
    primaryMuscle: 'Quads & Glutes', secondaryMuscles: 'Hamstrings',
    equipment: 'Machine', difficulty: 'Beginner',
    tips: 'Don\'t lock knees fully. Full range of motion. Foot position matters.',
  ),
  ExerciseItem(
    id: 'e-043', name: 'Romanian Deadlift (Dumbbell)', type: 'Strength',
    primaryMuscle: 'Hamstrings', secondaryMuscles: 'Glutes, Lower Back',
    equipment: 'Dumbbell', difficulty: 'Intermediate',
    tips: 'Hinge at hips. Feel stretch in hamstrings. Keep back flat.',
  ),
  ExerciseItem(
    id: 'e-044', name: 'Leg Curl (Machine, Lying)', type: 'Strength',
    primaryMuscle: 'Hamstrings', secondaryMuscles: '',
    equipment: 'Machine', difficulty: 'Beginner',
    tips: 'Full stretch. Pause at peak contraction. Slow negative.',
  ),
  ExerciseItem(
    id: 'e-045', name: 'Leg Extension (Machine)', type: 'Strength',
    primaryMuscle: 'Quads', secondaryMuscles: '',
    equipment: 'Machine', difficulty: 'Beginner',
    tips: 'Squeeze quads at top. Use moderate weight for joint health.',
  ),
  ExerciseItem(
    id: 'e-046', name: 'Bulgarian Split Squat', type: 'Strength',
    primaryMuscle: 'Quads & Glutes', secondaryMuscles: 'Hamstrings, Core',
    equipment: 'Dumbbell', difficulty: 'Advanced',
    tips: 'Rear foot elevated. Lead knee tracks over toes. Brutal but effective.',
  ),
  ExerciseItem(
    id: 'e-047', name: 'Standing Calf Raise', type: 'Strength',
    primaryMuscle: 'Calves (Gastrocnemius)', secondaryMuscles: '',
    equipment: 'Machine', difficulty: 'Beginner',
    tips: 'Full stretch at bottom. Pause at top. Use slow tempo.',
  ),
  ExerciseItem(
    id: 'e-048', name: 'Sumo Deadlift', type: 'Strength',
    primaryMuscle: 'Glutes & Inner Thighs', secondaryMuscles: 'Hamstrings, Quads',
    equipment: 'Barbell', difficulty: 'Advanced',
    tips: 'Wide stance, toes out. Shorter ROM. Great for glutes.',
  ),

  // ──────────────────────────── CORE ────────────────────────────
  ExerciseItem(
    id: 'e-051', name: 'Plank', type: 'Bodyweight',
    primaryMuscle: 'Core (Transverse Abdominis)', secondaryMuscles: 'Shoulders, Glutes',
    equipment: 'Bodyweight', difficulty: 'Beginner',
    tips: 'Neutral spine, squeeze glutes and abs. Don\'t let hips sag.',
  ),
  ExerciseItem(
    id: 'e-052', name: 'Crunches', type: 'Bodyweight',
    primaryMuscle: 'Rectus Abdominis', secondaryMuscles: '',
    equipment: 'Bodyweight', difficulty: 'Beginner',
    tips: 'Don\'t pull neck. Focus on curling upper back off floor.',
  ),
  ExerciseItem(
    id: 'e-053', name: 'Russian Twist', type: 'Bodyweight',
    primaryMuscle: 'Obliques', secondaryMuscles: 'Core',
    equipment: 'Bodyweight', difficulty: 'Beginner',
    tips: 'Add weight for progression. Feet off floor for more difficulty.',
  ),
  ExerciseItem(
    id: 'e-054', name: 'Cable Crunch', type: 'Strength',
    primaryMuscle: 'Rectus Abdominis', secondaryMuscles: 'Obliques',
    equipment: 'Cable', difficulty: 'Beginner',
    tips: 'Crunch ribcage to pelvis. Don\'t use hip flexors.',
  ),
  ExerciseItem(
    id: 'e-055', name: 'Hanging Leg Raise', type: 'Bodyweight',
    primaryMuscle: 'Lower Abs & Hip Flexors', secondaryMuscles: 'Lats, Core',
    equipment: 'Bodyweight', difficulty: 'Intermediate',
    tips: 'Control the swing. Curl pelvis at top. Advanced: toes to bar.',
  ),

  // ──────────────────────────── CARDIO ────────────────────────────
  ExerciseItem(
    id: 'e-061', name: 'Running (Outdoor/Treadmill)', type: 'Cardio',
    primaryMuscle: 'Full Body', secondaryMuscles: '',
    equipment: 'Bodyweight', difficulty: 'Beginner',
    tips: 'Land midfoot. Keep cadence ~170-180 spm. Stay aerobic zone.',
  ),
  ExerciseItem(
    id: 'e-062', name: 'Cycling (Stationary)', type: 'Cardio',
    primaryMuscle: 'Quads & Calves', secondaryMuscles: 'Glutes',
    equipment: 'Machine', difficulty: 'Beginner',
    tips: 'Adjust seat height (slight knee bend at bottom). Steady pace.',
  ),
  ExerciseItem(
    id: 'e-063', name: 'Rowing Machine', type: 'Cardio',
    primaryMuscle: 'Back & Cardio', secondaryMuscles: 'Legs, Arms',
    equipment: 'Machine', difficulty: 'Intermediate',
    tips: 'Drive with legs first, then lean back, then pull arms. Return in reverse.',
  ),
  ExerciseItem(
    id: 'e-064', name: 'Jump Rope (Skipping)', type: 'Cardio',
    primaryMuscle: 'Full Body', secondaryMuscles: 'Calves, Shoulders',
    equipment: 'Bodyweight', difficulty: 'Intermediate',
    tips: 'Light on feet. Wrist rotation, not arm swings. Great for conditioning.',
  ),
  ExerciseItem(
    id: 'e-065', name: 'Battle Ropes', type: 'Cardio',
    primaryMuscle: 'Shoulders & Core', secondaryMuscles: 'Arms, Back',
    equipment: 'Machine', difficulty: 'Intermediate',
    tips: '30s on, 30s off. Alternate waves or slam variations.',
  ),
  ExerciseItem(
    id: 'e-066', name: 'Stairmaster', type: 'Cardio',
    primaryMuscle: 'Glutes & Quads', secondaryMuscles: 'Calves, Cardio',
    equipment: 'Machine', difficulty: 'Beginner',
    tips: 'Don\'t lean on handles. Full step. Great for glute activation.',
  ),
  ExerciseItem(
    id: 'e-067', name: 'Elliptical Trainer', type: 'Cardio',
    primaryMuscle: 'Full Body', secondaryMuscles: '',
    equipment: 'Machine', difficulty: 'Beginner',
    tips: 'Low impact. Good for recovery days. Use handles for upper body.',
  ),
];
