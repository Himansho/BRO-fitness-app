class FoodItem {
  final String id;
  final String name;
  final String category;    // Indian|Global|Dairy|Protein|Grains|Fruits|Vegetables|Supplements
  final double calories;    // per 100g
  final double protein;     // g per 100g
  final double carbs;       // g per 100g
  final double fat;         // g per 100g
  final double fiber;       // g per 100g
  final double sugar;       // g per 100g
  final double sodium;      // mg per 100g
  final String servingUnit; // display info only

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    required this.servingUnit,
  });
}

const List<FoodItem> foodDatabase = [
  // ──────────────────────────── INDIAN DISHES ────────────────────────────
  FoodItem(id: 'f-001', name: 'Aloo Parantha', category: 'Indian', calories: 290, protein: 6, carbs: 45, fat: 10, fiber: 3.2, servingUnit: '1 piece (110g)'),
  FoodItem(id: 'f-002', name: 'Rajma Chawal', category: 'Indian', calories: 150, protein: 5, carbs: 26, fat: 3, fiber: 4.5, servingUnit: '100g'),
  FoodItem(id: 'f-003', name: 'Dal Makhani', category: 'Indian', calories: 160, protein: 5, carbs: 18, fat: 8, fiber: 3.8, servingUnit: '100g'),
  FoodItem(id: 'f-004', name: 'Whole Wheat Chapati (Roti)', category: 'Indian', calories: 85, protein: 3, carbs: 18, fat: 0.5, fiber: 2.1, servingUnit: '1 piece (30g)'),
  FoodItem(id: 'f-005', name: 'Paneer Butter Masala', category: 'Indian', calories: 229, protein: 8, carbs: 9, fat: 19, servingUnit: '100g'),
  FoodItem(id: 'f-006', name: 'Chicken Biryani', category: 'Indian', calories: 180, protein: 9, carbs: 22, fat: 6, servingUnit: '100g'),
  FoodItem(id: 'f-007', name: 'Idli (Plain)', category: 'Indian', calories: 58, protein: 1.6, carbs: 12, fat: 0.1, fiber: 0.5, servingUnit: '1 piece (40g)'),
  FoodItem(id: 'f-008', name: 'Sambar', category: 'Indian', calories: 75, protein: 2.5, carbs: 11, fat: 2.5, fiber: 2.8, servingUnit: '100g'),
  FoodItem(id: 'f-009', name: 'Masala Dosa', category: 'Indian', calories: 250, protein: 4, carbs: 40, fat: 8, fiber: 1.5, servingUnit: '1 piece (150g)'),
  FoodItem(id: 'f-010', name: 'Chicken Tikka', category: 'Indian', calories: 150, protein: 18, carbs: 4, fat: 7, servingUnit: '100g'),
  FoodItem(id: 'f-011', name: 'Chole Bhature', category: 'Indian', calories: 340, protein: 8, carbs: 42, fat: 16, fiber: 3.0, servingUnit: '100g'),
  FoodItem(id: 'f-012', name: 'Samosa (Fried)', category: 'Indian', calories: 262, protein: 3.5, carbs: 32, fat: 13, servingUnit: '1 piece (90g)'),
  FoodItem(id: 'f-013', name: 'Palak Paneer', category: 'Indian', calories: 140, protein: 6, carbs: 5, fat: 11, fiber: 2.0, servingUnit: '100g'),
  FoodItem(id: 'f-014', name: 'Tandoori Roti', category: 'Indian', calories: 110, protein: 4, carbs: 22, fat: 1, fiber: 2.5, servingUnit: '1 piece (40g)'),
  FoodItem(id: 'f-015', name: 'Khichdi (Moong Dal)', category: 'Indian', calories: 130, protein: 5, carbs: 22, fat: 3.5, fiber: 2.2, servingUnit: '100g'),
  FoodItem(id: 'f-016', name: 'Poha (Flattened Rice)', category: 'Indian', calories: 180, protein: 3, carbs: 35, fat: 4.5, fiber: 1.2, servingUnit: '100g'),
  FoodItem(id: 'f-017', name: 'Upma', category: 'Indian', calories: 150, protein: 3.5, carbs: 28, fat: 4, fiber: 1.5, servingUnit: '100g'),
  FoodItem(id: 'f-018', name: 'Moong Dal (Cooked)', category: 'Indian', calories: 105, protein: 7, carbs: 18, fat: 0.4, fiber: 4.0, servingUnit: '100g'),
  FoodItem(id: 'f-019', name: 'Toor Dal (Cooked)', category: 'Indian', calories: 115, protein: 6.5, carbs: 20, fat: 1, fiber: 3.5, servingUnit: '100g'),
  FoodItem(id: 'f-020', name: 'Mutton Curry', category: 'Indian', calories: 190, protein: 14, carbs: 5, fat: 13, servingUnit: '100g'),
  FoodItem(id: 'f-021', name: 'Fish Curry (Bengali)', category: 'Indian', calories: 165, protein: 16, carbs: 4, fat: 10, servingUnit: '100g'),
  FoodItem(id: 'f-022', name: 'Pav Bhaji', category: 'Indian', calories: 220, protein: 5, carbs: 38, fat: 7, fiber: 4.0, servingUnit: '100g'),
  FoodItem(id: 'f-023', name: 'Egg Bhurji (Spiced Scrambled Eggs)', category: 'Indian', calories: 170, protein: 12, carbs: 3, fat: 12, servingUnit: '100g'),
  FoodItem(id: 'f-024', name: 'Chana Masala', category: 'Indian', calories: 145, protein: 7, carbs: 22, fat: 4, fiber: 5.5, servingUnit: '100g'),
  FoodItem(id: 'f-025', name: 'Aloo Gobi', category: 'Indian', calories: 100, protein: 2.5, carbs: 15, fat: 4, fiber: 3.0, servingUnit: '100g'),
  FoodItem(id: 'f-026', name: 'Butter Chicken (Murgh Makhani)', category: 'Indian', calories: 185, protein: 14, carbs: 8, fat: 12, servingUnit: '100g'),
  FoodItem(id: 'f-027', name: 'Lassi (Sweet)', category: 'Indian', calories: 90, protein: 3.5, carbs: 15, fat: 2.5, servingUnit: '100ml'),
  FoodItem(id: 'f-028', name: 'Chaas (Buttermilk)', category: 'Indian', calories: 30, protein: 1.5, carbs: 4, fat: 0.5, servingUnit: '100ml'),

  // ──────────────────────────── PROTEIN FOODS ────────────────────────────
  FoodItem(id: 'f-101', name: 'Chicken Breast (Grilled)', category: 'Protein', calories: 165, protein: 31, carbs: 0, fat: 3.6, servingUnit: '100g'),
  FoodItem(id: 'f-102', name: 'Boiled Egg (Whole)', category: 'Protein', calories: 155, protein: 13, carbs: 1.1, fat: 11, servingUnit: '100g'),
  FoodItem(id: 'f-103', name: 'Egg White (Large)', category: 'Protein', calories: 17, protein: 3.6, carbs: 0.2, fat: 0.1, servingUnit: '1 white (33g)'),
  FoodItem(id: 'f-104', name: 'Salmon (Grilled)', category: 'Protein', calories: 206, protein: 22, carbs: 0, fat: 12, servingUnit: '100g'),
  FoodItem(id: 'f-105', name: 'Tuna (Canned in Water)', category: 'Protein', calories: 116, protein: 26, carbs: 0, fat: 1, servingUnit: '100g'),
  FoodItem(id: 'f-106', name: 'Cottage Cheese (Paneer — Raw)', category: 'Protein', calories: 265, protein: 18, carbs: 1.2, fat: 21, servingUnit: '100g'),
  FoodItem(id: 'f-107', name: 'Greek Yogurt (Plain, Non-Fat)', category: 'Protein', calories: 59, protein: 10, carbs: 3.6, fat: 0.4, servingUnit: '100g'),
  FoodItem(id: 'f-108', name: 'Whey Protein (1 Scoop)', category: 'Supplements', calories: 120, protein: 24, carbs: 3, fat: 1.5, servingUnit: '1 scoop (30g)'),
  FoodItem(id: 'f-109', name: 'Casein Protein (1 Scoop)', category: 'Supplements', calories: 120, protein: 24, carbs: 3, fat: 1, servingUnit: '1 scoop (30g)'),
  FoodItem(id: 'f-110', name: 'Turkey Breast (Cooked)', category: 'Protein', calories: 189, protein: 29, carbs: 0, fat: 7.4, servingUnit: '100g'),
  FoodItem(id: 'f-111', name: 'Lamb (Lean, Grilled)', category: 'Protein', calories: 218, protein: 25, carbs: 0, fat: 12.5, servingUnit: '100g'),
  FoodItem(id: 'f-112', name: 'Tofu (Firm)', category: 'Protein', calories: 76, protein: 8, carbs: 1.9, fat: 4.2, servingUnit: '100g'),
  FoodItem(id: 'f-113', name: 'Tempeh', category: 'Protein', calories: 195, protein: 20, carbs: 9, fat: 11, fiber: 4.6, servingUnit: '100g'),
  FoodItem(id: 'f-114', name: 'Edamame (Boiled)', category: 'Protein', calories: 122, protein: 11, carbs: 9.9, fat: 5.2, fiber: 5.2, servingUnit: '100g'),

  // ──────────────────────────── CARBS & GRAINS ────────────────────────────
  FoodItem(id: 'f-201', name: 'Oatmeal (Rolled Oats, Dry)', category: 'Grains', calories: 389, protein: 17, carbs: 66, fat: 7, fiber: 10.6, servingUnit: '100g'),
  FoodItem(id: 'f-202', name: 'White Rice (Cooked)', category: 'Grains', calories: 130, protein: 2.7, carbs: 28, fat: 0.3, servingUnit: '100g'),
  FoodItem(id: 'f-203', name: 'Brown Rice (Cooked)', category: 'Grains', calories: 112, protein: 2.6, carbs: 23, fat: 0.9, fiber: 1.8, servingUnit: '100g'),
  FoodItem(id: 'f-204', name: 'Quinoa (Cooked)', category: 'Grains', calories: 120, protein: 4.4, carbs: 21, fat: 1.9, fiber: 2.8, servingUnit: '100g'),
  FoodItem(id: 'f-205', name: 'Sweet Potato (Baked)', category: 'Grains', calories: 90, protein: 2, carbs: 21, fat: 0.1, fiber: 3.3, servingUnit: '100g'),
  FoodItem(id: 'f-206', name: 'Whole Wheat Bread (1 slice)', category: 'Grains', calories: 69, protein: 3.6, carbs: 12, fat: 1, fiber: 1.9, servingUnit: '1 slice (28g)'),
  FoodItem(id: 'f-207', name: 'Pasta (Cooked, Plain)', category: 'Grains', calories: 158, protein: 5.8, carbs: 31, fat: 0.9, servingUnit: '100g'),
  FoodItem(id: 'f-208', name: 'Corn Tortilla (6-inch)', category: 'Grains', calories: 52, protein: 1.4, carbs: 11, fat: 0.7, fiber: 1.5, servingUnit: '1 tortilla (24g)'),

  // ──────────────────────────── FRUITS ────────────────────────────
  FoodItem(id: 'f-301', name: 'Banana (Medium)', category: 'Fruits', calories: 89, protein: 1.1, carbs: 23, fat: 0.3, fiber: 2.6, sugar: 12, servingUnit: '1 medium (118g)'),
  FoodItem(id: 'f-302', name: 'Apple (Medium)', category: 'Fruits', calories: 52, protein: 0.3, carbs: 14, fat: 0.2, fiber: 2.4, sugar: 10, servingUnit: '1 medium (182g)'),
  FoodItem(id: 'f-303', name: 'Mango (Alphonso)', category: 'Fruits', calories: 60, protein: 0.8, carbs: 15, fat: 0.4, fiber: 1.6, sugar: 13.7, servingUnit: '100g'),
  FoodItem(id: 'f-304', name: 'Blueberries', category: 'Fruits', calories: 57, protein: 0.7, carbs: 14, fat: 0.3, fiber: 2.4, sugar: 10, servingUnit: '100g'),
  FoodItem(id: 'f-305', name: 'Orange (Medium)', category: 'Fruits', calories: 47, protein: 0.9, carbs: 12, fat: 0.1, fiber: 2.4, sugar: 9.4, servingUnit: '1 medium (131g)'),
  FoodItem(id: 'f-306', name: 'Watermelon', category: 'Fruits', calories: 30, protein: 0.6, carbs: 7.6, fat: 0.2, fiber: 0.4, sugar: 6.2, servingUnit: '100g'),
  FoodItem(id: 'f-307', name: 'Dates (Medjool)', category: 'Fruits', calories: 277, protein: 1.8, carbs: 75, fat: 0.2, fiber: 6.7, sugar: 63, servingUnit: '100g'),
  FoodItem(id: 'f-308', name: 'Avocado', category: 'Fruits', calories: 160, protein: 2, carbs: 8.5, fat: 15, fiber: 6.7, servingUnit: '100g'),

  // ──────────────────────────── VEGETABLES ────────────────────────────
  FoodItem(id: 'f-401', name: 'Broccoli (Steamed)', category: 'Vegetables', calories: 35, protein: 2.8, carbs: 7, fat: 0.4, fiber: 2.6, servingUnit: '100g'),
  FoodItem(id: 'f-402', name: 'Spinach (Raw)', category: 'Vegetables', calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2, servingUnit: '100g'),
  FoodItem(id: 'f-403', name: 'Mixed Salad Greens', category: 'Vegetables', calories: 15, protein: 1.4, carbs: 2.8, fat: 0.2, fiber: 1.8, servingUnit: '100g'),
  FoodItem(id: 'f-404', name: 'Cucumber', category: 'Vegetables', calories: 15, protein: 0.7, carbs: 3.6, fat: 0.1, fiber: 0.5, servingUnit: '100g'),
  FoodItem(id: 'f-405', name: 'Tomato (Raw)', category: 'Vegetables', calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2, servingUnit: '100g'),
  FoodItem(id: 'f-406', name: 'Carrot (Raw)', category: 'Vegetables', calories: 41, protein: 0.9, carbs: 10, fat: 0.2, fiber: 2.8, servingUnit: '100g'),

  // ──────────────────────────── DAIRY ────────────────────────────
  FoodItem(id: 'f-501', name: 'Whole Milk', category: 'Dairy', calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3, servingUnit: '100ml'),
  FoodItem(id: 'f-502', name: 'Skimmed Milk', category: 'Dairy', calories: 34, protein: 3.4, carbs: 4.9, fat: 0.1, servingUnit: '100ml'),
  FoodItem(id: 'f-503', name: 'Cheddar Cheese', category: 'Dairy', calories: 402, protein: 25, carbs: 1.3, fat: 33, servingUnit: '100g'),
  FoodItem(id: 'f-504', name: 'Butter', category: 'Dairy', calories: 717, protein: 0.9, carbs: 0.1, fat: 81, servingUnit: '100g'),

  // ──────────────────────────── NUTS & FATS ────────────────────────────
  FoodItem(id: 'f-601', name: 'Almonds (Raw)', category: 'Nuts', calories: 579, protein: 21, carbs: 22, fat: 49, fiber: 12.5, servingUnit: '100g'),
  FoodItem(id: 'f-602', name: 'Walnuts', category: 'Nuts', calories: 654, protein: 15, carbs: 14, fat: 65, fiber: 6.7, servingUnit: '100g'),
  FoodItem(id: 'f-603', name: 'Peanut Butter (Unsweetened)', category: 'Nuts', calories: 588, protein: 25, carbs: 20, fat: 50, fiber: 6, servingUnit: '100g'),
  FoodItem(id: 'f-604', name: 'Olive Oil', category: 'Fats', calories: 884, protein: 0, carbs: 0, fat: 100, servingUnit: '100ml'),
  FoodItem(id: 'f-605', name: 'Coconut Oil', category: 'Fats', calories: 862, protein: 0, carbs: 0, fat: 100, servingUnit: '100ml'),
  FoodItem(id: 'f-606', name: 'Chia Seeds', category: 'Nuts', calories: 486, protein: 17, carbs: 42, fat: 31, fiber: 34.4, servingUnit: '100g'),
  FoodItem(id: 'f-607', name: 'Flaxseeds', category: 'Nuts', calories: 534, protein: 18, carbs: 29, fat: 42, fiber: 27, servingUnit: '100g'),

  // ──────────────────────────── SUPPLEMENTS / GYM ────────────────────────────
  FoodItem(id: 'f-701', name: 'Mass Gainer (1 Serving)', category: 'Supplements', calories: 400, protein: 28, carbs: 60, fat: 5, servingUnit: '1 serving (100g)'),
  FoodItem(id: 'f-702', name: 'BCAA (1 Serving)', category: 'Supplements', calories: 15, protein: 5, carbs: 0, fat: 0, servingUnit: '1 serving (10g)'),
  FoodItem(id: 'f-703', name: 'Creatine Monohydrate (5g)', category: 'Supplements', calories: 0, protein: 0, carbs: 0, fat: 0, servingUnit: '5g'),
  FoodItem(id: 'f-704', name: 'Energy Bar (Clif Bar style)', category: 'Supplements', calories: 250, protein: 10, carbs: 44, fat: 5, fiber: 5, servingUnit: '1 bar (68g)'),
  FoodItem(id: 'f-705', name: 'Pre-Workout (1 Scoop)', category: 'Supplements', calories: 10, protein: 0, carbs: 2, fat: 0, servingUnit: '1 scoop (5g)'),
];
