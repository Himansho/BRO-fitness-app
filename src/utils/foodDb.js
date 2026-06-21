// Preloaded offline databases for foods and exercises to allow fully offline functionality.

export const FOOD_DATABASE = [
  // --- Indian Dishes ---
  { id: 'f-1', name: 'Aloo Parantha', category: 'Indian', calories: 290, protein: 6, carbs: 45, fat: 10, servingUnit: 'piece (110g)' },
  { id: 'f-2', name: 'Rajma Chawal (Kidney Beans & Rice)', category: 'Indian', calories: 150, protein: 5, carbs: 26, fat: 3, servingUnit: '100g' },
  { id: 'f-3', name: 'Dal Makhani', category: 'Indian', calories: 160, protein: 5, carbs: 18, fat: 8, servingUnit: '100g' },
  { id: 'f-4', name: 'Roti (Whole Wheat Chapati)', category: 'Indian', calories: 85, protein: 3, carbs: 18, fat: 0.5, servingUnit: 'piece (30g)' },
  { id: 'f-5', name: 'Paneer Butter Masala', category: 'Indian', calories: 229, protein: 8, carbs: 9, fat: 19, servingUnit: '100g' },
  { id: 'f-6', name: 'Chicken Biryani', category: 'Indian', calories: 180, protein: 9, carbs: 22, fat: 6, servingUnit: '100g' },
  { id: 'f-7', name: 'Idli', category: 'Indian', calories: 58, protein: 1.6, carbs: 12, fat: 0.1, servingUnit: 'piece (40g)' },
  { id: 'f-8', name: 'Sambar', category: 'Indian', calories: 75, protein: 2.5, carbs: 11, fat: 2.5, servingUnit: '100g' },
  { id: 'f-9', name: 'Masala Dosa', category: 'Indian', calories: 250, protein: 4, carbs: 40, fat: 8, servingUnit: 'piece (150g)' },
  { id: 'f-10', name: 'Chicken Tikka', category: 'Indian', calories: 150, protein: 18, carbs: 4, fat: 7, servingUnit: '100g' },
  { id: 'f-11', name: 'Chole Bhature', category: 'Indian', calories: 340, protein: 8, carbs: 42, fat: 16, servingUnit: '100g' },
  { id: 'f-12', name: 'Samosa', category: 'Indian', calories: 262, protein: 3.5, carbs: 32, fat: 13, servingUnit: 'piece (90g)' },
  { id: 'f-13', name: 'Palak Paneer', category: 'Indian', calories: 140, protein: 6, carbs: 5, fat: 11, servingUnit: '100g' },
  { id: 'f-14', name: 'Tandoori Roti', category: 'Indian', calories: 110, protein: 4, carbs: 22, fat: 1, servingUnit: 'piece (40g)' },

  // --- International & Clean Fitness Foods ---
  { id: 'f-20', name: 'Chicken Breast (Grilled)', category: 'Global', calories: 165, protein: 31, carbs: 0, fat: 3.6, servingUnit: '100g' },
  { id: 'f-21', name: 'Oatmeal (Cooked in Water)', category: 'Global', calories: 68, protein: 2.4, carbs: 12, fat: 1.4, servingUnit: '100g' },
  { id: 'f-22', name: 'White Rice (Cooked)', category: 'Global', calories: 130, protein: 2.7, carbs: 28, fat: 0.3, servingUnit: '100g' },
  { id: 'f-23', name: 'Brown Rice (Cooked)', category: 'Global', calories: 112, protein: 2.6, carbs: 23, fat: 0.9, servingUnit: '100g' },
  { id: 'f-24', name: 'Boiled Egg (Large)', category: 'Global', calories: 78, protein: 6.3, carbs: 0.6, fat: 5.3, servingUnit: 'piece (50g)' },
  { id: 'f-25', name: 'Egg White (Large)', category: 'Global', calories: 17, protein: 3.6, carbs: 0.2, fat: 0.1, servingUnit: 'piece (33g)' },
  { id: 'f-26', name: 'Salmon (Grilled)', category: 'Global', calories: 206, protein: 22, carbs: 0, fat: 12, servingUnit: '100g' },
  { id: 'f-27', name: 'Avocado', category: 'Global', calories: 160, protein: 2, carbs: 8.5, fat: 15, servingUnit: '100g' },
  { id: 'f-28', name: 'Whey Protein Shake (1 Scoop)', category: 'Global', calories: 120, protein: 24, carbs: 3, fat: 1.5, servingUnit: 'scoop (30g)' },
  { id: 'f-29', name: 'Banana', category: 'Global', calories: 89, protein: 1.1, carbs: 23, fat: 0.3, servingUnit: 'medium (118g)' },
  { id: 'f-30', name: 'Apple', category: 'Global', calories: 52, protein: 0.3, carbs: 14, fat: 0.2, servingUnit: 'medium (182g)' },
  { id: 'f-31', name: 'Greek Yogurt (Plain, Non-Fat)', category: 'Global', calories: 59, protein: 10, carbs: 3.6, fat: 0.4, servingUnit: '100g' },
  { id: 'f-32', name: 'Broccoli (Steamed)', category: 'Global', calories: 35, protein: 2.8, carbs: 7, fat: 0.4, servingUnit: '100g' },
  { id: 'f-33', name: 'Almonds', category: 'Global', calories: 579, protein: 21, carbs: 22, fat: 49, servingUnit: '100g' },
  { id: 'f-34', name: 'Mixed Salad Greens', category: 'Global', calories: 15, protein: 1.4, carbs: 2.8, fat: 0.2, servingUnit: '100g' },
  { id: 'f-35', name: 'Peanut Butter', category: 'Global', calories: 588, protein: 25, carbs: 20, fat: 50, servingUnit: '100g' }
];

export const EXERCISE_DATABASE = [
  // --- Strength / Resistance ---
  { id: 'e-1', name: 'Bench Press', type: 'Strength', primaryMuscle: 'Chest' },
  { id: 'e-2', name: 'Squat (Barbell)', type: 'Strength', primaryMuscle: 'Quads' },
  { id: 'e-3', name: 'Deadlift (Barbell)', type: 'Strength', primaryMuscle: 'Hamstrings & Back' },
  { id: 'e-4', name: 'Overhead Press (Barbell)', type: 'Strength', primaryMuscle: 'Shoulders' },
  { id: 'e-5', name: 'Bicep Curl (Dumbbell)', type: 'Strength', primaryMuscle: 'Biceps' },
  { id: 'e-6', name: 'Tricep Pushdown (Cable)', type: 'Strength', primaryMuscle: 'Triceps' },
  { id: 'e-7', name: 'Lat Pulldown', type: 'Strength', primaryMuscle: 'Lats' },
  { id: 'e-8', name: 'Barbell Row', type: 'Strength', primaryMuscle: 'Upper Back' },
  { id: 'e-9', name: 'Incline Dumbbell Press', type: 'Strength', primaryMuscle: 'Upper Chest' },
  { id: 'e-10', name: 'Leg Press', type: 'Strength', primaryMuscle: 'Legs' },
  { id: 'e-11', name: 'Lateral Raise (Dumbbell)', type: 'Strength', primaryMuscle: 'Lateral Delts' },
  { id: 'e-12', name: 'Pull-Up', type: 'Strength', primaryMuscle: 'Back & Lats' },
  { id: 'e-13', name: 'Push-Up', type: 'Strength', primaryMuscle: 'Chest & Arms' },

  // --- Cardio / Endurance ---
  { id: 'e-20', name: 'Running', type: 'Cardio', primaryMuscle: 'Full Body' },
  { id: 'e-21', name: 'Cycling', type: 'Cardio', primaryMuscle: 'Quads & Calves' },
  { id: 'e-22', name: 'Treadmill Walk', type: 'Cardio', primaryMuscle: 'Legs' },
  { id: 'e-23', name: 'Rowing Machine', type: 'Cardio', primaryMuscle: 'Back & Cardio' },
  { id: 'e-24', name: 'Elliptical Trainer', type: 'Cardio', primaryMuscle: 'Full Body' },
  { id: 'e-25', name: 'Swimming', type: 'Cardio', primaryMuscle: 'Full Body' }
];
