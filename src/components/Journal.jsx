import React, { useState, useEffect } from 'react';
import { db } from '../utils/db';
import { FOOD_DATABASE, EXERCISE_DATABASE } from '../utils/foodDb';

export default function Journal({ activeDate, setActiveDate, onLogUpdated }) {
  const [dailyLog, setDailyLog] = useState({
    meals: [],
    workouts: [],
    water: 0,
    steps: 0,
    activeCalories: 0,
    heartRate: 0
  });

  const [recentMeals, setRecentMeals] = useState([]);
  
  // Modals state
  const [showAddSelector, setShowAddSelector] = useState(false);
  const [showMealModal, setShowMealModal] = useState(false);
  const [showWorkoutModal, setShowWorkoutModal] = useState(false);

  // Meal Modal Form State
  const [mealCategory, setMealCategory] = useState('Breakfast');
  const [foodSearch, setFoodSearch] = useState('');
  const [selectedFood, setSelectedFood] = useState(null);
  const [mealPortion, setMealPortion] = useState(100); // in grams or servings
  const [customFoodName, setCustomFoodName] = useState('');
  const [customCalories, setCustomCalories] = useState('');
  const [customProtein, setCustomProtein] = useState('');
  const [customCarbs, setCustomCarbs] = useState('');
  const [customFat, setCustomFat] = useState('');
  const [isCustomFood, setIsCustomFood] = useState(false);

  // Workout Modal Form State
  const [exerciseSearch, setExerciseSearch] = useState('');
  const [selectedExercise, setSelectedExercise] = useState(null);
  const [workoutSets, setWorkoutSets] = useState([{ weight: '', reps: '' }]);
  const [prevSessionText, setPrevSessionText] = useState('');
  const [prevSessionSets, setPrevSessionSets] = useState([]);
  const [customExerciseName, setCustomExerciseName] = useState('');
  const [isCustomExercise, setIsCustomExercise] = useState(false);

  useEffect(() => {
    loadDailyLog();
    loadRecentMeals();
  }, [activeDate]);

  const loadDailyLog = async () => {
    try {
      const log = await db.getDailyLog(activeDate);
      setDailyLog(log);
    } catch (err) {
      console.error(err);
    }
  };

  // Find recent unique meals logged in the past 14 days
  const loadRecentMeals = async () => {
    try {
      const recents = [];
      const today = new Date(activeDate);
      
      for (let i = 1; i <= 14; i++) {
        const d = new Date(today);
        d.setDate(today.getDate() - i);
        const dateStr = d.toISOString().split('T')[0];
        const dayLog = await db.getDailyLog(dateStr);
        
        if (dayLog && dayLog.meals) {
          dayLog.meals.forEach(m => {
            if (!recents.some(r => r.name.toLowerCase() === m.name.toLowerCase())) {
              recents.push(m);
            }
          });
        }
      }
      setRecentMeals(recents.slice(0, 5)); // top 5
    } catch (err) {
      console.error(err);
    }
  };

  // Date Navigators
  const changeDate = (days) => {
    const d = new Date(activeDate);
    d.setDate(d.getDate() + days);
    setActiveDate(d.toISOString().split('T')[0]);
  };

  const setToday = () => {
    setActiveDate(new Date().toISOString().split('T')[0]);
  };

  // Load Progressive Overload Target for selected exercise
  const loadExerciseHistory = async (exerciseName) => {
    setPrevSessionText('No previous session found.');
    setPrevSessionSets([]);
    
    try {
      const today = new Date(activeDate);
      
      // Look back up to 30 days
      for (let i = 1; i <= 30; i++) {
        const d = new Date(today);
        d.setDate(today.getDate() - i);
        const dateStr = d.toISOString().split('T')[0];
        
        const dayLog = await db.getDailyLog(dateStr);
        if (dayLog && dayLog.workouts) {
          const matchedEx = dayLog.workouts.find(w => w.name.toLowerCase() === exerciseName.toLowerCase());
          if (matchedEx) {
            const setDesc = matchedEx.sets.map((s, idx) => `${s.weight}kg × ${s.reps}`).join(', ');
            setPrevSessionText(`Last on ${dateStr}: ${setDesc}`);
            setPrevSessionSets(matchedEx.sets);
            
            // Set placeholders/defaults as the previous session values!
            setWorkoutSets(matchedEx.sets.map(s => ({ weight: s.weight, reps: s.reps })));
            return;
          }
        }
      }
      
      // Default empty set if no history
      setWorkoutSets([{ weight: '', reps: '' }]);
    } catch (err) {
      console.error(err);
    }
  };

  // Add Meal Submit
  const handleAddMeal = async (e) => {
    e.preventDefault();
    
    let mealItem = null;
    
    if (isCustomFood) {
      if (!customFoodName) return;
      mealItem = {
        id: 'meal-' + Date.now(),
        name: customFoodName,
        category: mealCategory,
        calories: parseInt(customCalories) || 0,
        protein: parseInt(customProtein) || 0,
        carbs: parseInt(customCarbs) || 0,
        fat: parseInt(customFat) || 0,
        portionSize: mealPortion,
        servingUnit: 'g',
        timestamp: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
      };
    } else {
      if (!selectedFood) return;
      const factor = mealPortion / 100;
      mealItem = {
        id: 'meal-' + Date.now(),
        name: selectedFood.name,
        category: mealCategory,
        calories: Math.round(selectedFood.calories * factor),
        protein: Math.round(selectedFood.protein * factor),
        carbs: Math.round(selectedFood.carbs * factor),
        fat: Math.round(selectedFood.fat * factor),
        portionSize: mealPortion,
        servingUnit: 'g',
        timestamp: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
      };
    }

    try {
      const updatedLog = {
        ...dailyLog,
        meals: [...dailyLog.meals, mealItem]
      };
      
      await db.saveDailyLog(activeDate, updatedLog);
      setDailyLog(updatedLog);
      
      // Close & Reset
      setShowMealModal(false);
      setSelectedFood(null);
      setFoodSearch('');
      setMealPortion(100);
      setIsCustomFood(false);
      setCustomFoodName('');
      setCustomCalories('');
      setCustomProtein('');
      setCustomCarbs('');
      setCustomFat('');
      
      loadRecentMeals();
      onLogUpdated();
    } catch (err) {
      console.error(err);
    }
  };

  // Delete log item
  const handleDeleteMeal = async (mealId) => {
    try {
      const updatedLog = {
        ...dailyLog,
        meals: dailyLog.meals.filter(m => m.id !== mealId)
      };
      await db.saveDailyLog(activeDate, updatedLog);
      setDailyLog(updatedLog);
      onLogUpdated();
    } catch (err) {
      console.error(err);
    }
  };

  // Add Set
  const handleAddSet = () => {
    setWorkoutSets([...workoutSets, { weight: '', reps: '' }]);
  };

  // Remove Set
  const handleRemoveSet = (index) => {
    const newSets = [...workoutSets];
    newSets.splice(index, 1);
    setWorkoutSets(newSets);
  };

  const handleSetChange = (index, field, value) => {
    const newSets = [...workoutSets];
    newSets[index][field] = value;
    setWorkoutSets(newSets);
  };

  // Add Workout Submit
  const handleAddWorkout = async (e) => {
    e.preventDefault();
    
    let exerciseName = '';
    if (isCustomExercise) {
      if (!customExerciseName) return;
      exerciseName = customExerciseName;
    } else {
      if (!selectedExercise) return;
      exerciseName = selectedExercise.name;
    }

    // Filter out incomplete sets
    const cleanSets = workoutSets
      .filter(s => s.weight !== '' && s.reps !== '')
      .map(s => ({
        weight: parseFloat(s.weight),
        reps: parseInt(s.reps)
      }));

    if (cleanSets.length === 0) return;

    // Progressive overload comparison note
    let analysisMsg = '';
    if (prevSessionSets.length > 0) {
      const todayMax = Math.max(...cleanSets.map(s => s.weight));
      const prevMax = Math.max(...prevSessionSets.map(s => s.weight));
      
      if (todayMax > prevMax) {
        analysisMsg = `🔥 Progressive Overload! +${(todayMax - prevMax).toFixed(1)}kg max lift.`;
      } else if (todayMax === prevMax) {
        const todayTotalReps = cleanSets.reduce((sum, s) => sum + s.reps, 0);
        const prevTotalReps = prevSessionSets.reduce((sum, s) => sum + s.reps, 0);
        if (todayTotalReps > prevTotalReps) {
          analysisMsg = `🔥 Progressive Overload! +${todayTotalReps - prevTotalReps} extra reps.`;
        } else {
          analysisMsg = '💪 Solid session! Matched previous performance.';
        }
      } else {
        analysisMsg = '🏋️ Workout completed. Keep showing up!';
      }
    }

    const workoutItem = {
      id: 'workout-' + Date.now(),
      name: exerciseName,
      sets: cleanSets,
      analysis: analysisMsg,
      timestamp: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
    };

    try {
      const updatedLog = {
        ...dailyLog,
        workouts: [...dailyLog.workouts, workoutItem]
      };
      
      await db.saveDailyLog(activeDate, updatedLog);
      setDailyLog(updatedLog);
      
      // Close & Reset
      setShowWorkoutModal(false);
      setSelectedExercise(null);
      setExerciseSearch('');
      setWorkoutSets([{ weight: '', reps: '' }]);
      setPrevSessionText('');
      setPrevSessionSets([]);
      setIsCustomExercise(false);
      setCustomExerciseName('');

      onLogUpdated();
    } catch (err) {
      console.error(err);
    }
  };

  // Delete workout item
  const handleDeleteWorkout = async (workoutId) => {
    try {
      const updatedLog = {
        ...dailyLog,
        workouts: dailyLog.workouts.filter(w => w.id !== workoutId)
      };
      await db.saveDailyLog(activeDate, updatedLog);
      setDailyLog(updatedLog);
      onLogUpdated();
    } catch (err) {
      console.error(err);
    }
  };

  // Water Tracking Quick Increments
  const adjustWater = async (amount) => {
    try {
      const updatedLog = {
        ...dailyLog,
        water: Math.max(dailyLog.water + amount, 0)
      };
      await db.saveDailyLog(activeDate, updatedLog);
      setDailyLog(updatedLog);
      onLogUpdated();
    } catch (err) {
      console.error(err);
    }
  };

  // Search Filters
  const filteredFoods = foodSearch
    ? FOOD_DATABASE.filter(f => f.name.toLowerCase().includes(foodSearch.toLowerCase()))
    : [];

  const filteredExercises = exerciseSearch
    ? EXERCISE_DATABASE.filter(e => e.name.toLowerCase().includes(exerciseSearch.toLowerCase()))
    : [];

  // Grouped meal timeline display
  const totalCaloriesConsumed = dailyLog.meals.reduce((sum, m) => sum + m.calories, 0);

  return (
    <div className="tab-content animate-fade-in" style={{ paddingBottom: '80px' }}>
      
      {/* 1. TIMELINE DATE NAVIGATOR */}
      <div style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        background: 'var(--bg-card)',
        border: '1px solid var(--border-color)',
        borderRadius: 'var(--radius-md)',
        padding: '12px 16px'
      }}>
        <button onClick={() => changeDate(-1)} className="btn btn-secondary" style={{ width: 'auto', padding: '8px 12px' }}>
          ◀ Prev
        </button>
        <div style={{ textAlign: 'center', cursor: 'pointer' }} onClick={setToday}>
          <span style={{ fontSize: '15px', fontWeight: 700, color: '#fff', display: 'block' }}>
            {new Date(activeDate).toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric' })}
          </span>
          {activeDate === new Date().toISOString().split('T')[0] && (
            <span style={{ fontSize: '10px', color: '#00f2fe', fontWeight: 600, textTransform: 'uppercase' }}>Today</span>
          )}
        </div>
        <button onClick={() => changeDate(1)} className="btn btn-secondary" style={{ width: 'auto', padding: '8px 12px' }}>
          Next ▶
        </button>
      </div>

      {/* 2. QUICK HYDRATION (WATER LOG) */}
      <div className="card" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ textAlign: 'left' }}>
          <h3 style={{ fontSize: '14px', color: '#9ca3af', fontWeight: 600 }}>Water Intake</h3>
          <span style={{ fontSize: '20px', fontWeight: 800, color: '#3b82f6' }}>{dailyLog.water} ml</span>
        </div>
        <div style={{ display: 'flex', gap: '8px' }}>
          <button onClick={() => adjustWater(-250)} className="btn btn-secondary" style={{ width: 'auto', padding: '8px 14px' }}>-250ml</button>
          <button onClick={() => adjustWater(250)} className="btn btn-primary" style={{ width: 'auto', padding: '8px 14px', background: 'linear-gradient(135deg, #2563eb, #3b82f6)', color: '#fff' }}>+250ml</button>
        </div>
      </div>

      {/* 3. TIMELINE EVENTS */}
      <div className="card" style={{ padding: '24px 20px', textAlign: 'left' }}>
        <h3 style={{ fontSize: '15px', color: '#9ca3af', fontWeight: 600, marginBottom: '16px' }}>Timeline Journal</h3>

        {dailyLog.meals.length === 0 && dailyLog.workouts.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px 20px', color: '#6b7280' }}>
            <svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" style={{ marginBottom: '12px' }}>
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
              <polyline points="14 2 14 8 20 8" />
              <line x1="16" y1="13" x2="8" y2="13" />
              <line x1="16" y1="17" x2="8" y2="17" />
              <polyline points="10 9 9 9 8 9" />
            </svg>
            <p style={{ fontSize: '14px' }}>Timeline empty. Log your meals and exercises below.</p>
          </div>
        ) : (
          <div className="timeline">
            {/* Display Meals */}
            {dailyLog.meals.map((meal) => (
              <div key={meal.id} className="timeline-item">
                <div className="timeline-dot meal" />
                <div style={{
                  background: '#12141c',
                  border: '1px solid #2b3042',
                  borderRadius: '12px',
                  padding: '12px 16px',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center'
                }}>
                  <div>
                    <span style={{ fontSize: '11px', color: '#00f2fe', fontWeight: 600, textTransform: 'uppercase' }}>
                      {meal.category} • {meal.timestamp}
                    </span>
                    <h4 style={{ fontSize: '15px', fontWeight: 600, color: '#fff', margin: '2px 0 4px' }}>{meal.name}</h4>
                    <div className="log-item-details">
                      <span>{meal.portionSize}g</span>
                      <span>•</span>
                      <span style={{ color: '#fff' }}>{meal.calories} kcal</span>
                      <span>•</span>
                      <span>P: {meal.protein}g</span>
                      <span>C: {meal.carbs}g</span>
                      <span>F: {meal.fat}g</span>
                    </div>
                  </div>
                  <button onClick={() => handleDeleteMeal(meal.id)} className="log-item-delete">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <polyline points="3 6 5 6 21 6" />
                      <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
                    </svg>
                  </button>
                </div>
              </div>
            ))}

            {/* Display Workouts */}
            {dailyLog.workouts.map((workout) => (
              <div key={workout.id} className="timeline-item">
                <div className="timeline-dot workout" />
                <div style={{
                  background: '#12141c',
                  border: '1px solid #2b3042',
                  borderRadius: '12px',
                  padding: '12px 16px',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center'
                }}>
                  <div style={{ flex: 1, marginRight: '12px' }}>
                    <span style={{ fontSize: '11px', color: '#8b5cf6', fontWeight: 600, textTransform: 'uppercase' }}>
                      Strength • {workout.timestamp}
                    </span>
                    <h4 style={{ fontSize: '15px', fontWeight: 600, color: '#fff', margin: '2px 0 4px' }}>{workout.name}</h4>
                    
                    <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px', margin: '6px 0' }}>
                      {workout.sets.map((s, idx) => (
                        <span key={idx} style={{ background: '#1a1d28', padding: '3px 8px', borderRadius: '6px', fontSize: '11px', border: '1px solid #2b3042', color: '#e5e7eb' }}>
                          Set {idx + 1}: <strong>{s.weight}kg</strong> × {s.reps}
                        </span>
                      ))}
                    </div>
                    
                    {workout.analysis && (
                      <span style={{ fontSize: '11px', color: '#10b981', fontWeight: 600, display: 'block', marginTop: '4px' }}>
                        {workout.analysis}
                      </span>
                    )}
                  </div>
                  <button onClick={() => handleDeleteWorkout(workout.id)} className="log-item-delete">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <polyline points="3 6 5 6 21 6" />
                      <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
                    </svg>
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Floating Action Button (FAB) Selector */}
      <button 
        onClick={() => setShowAddSelector(true)} 
        className="btn-floating"
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <line x1="12" y1="5" x2="12" y2="19" />
          <line x1="5" y1="12" x2="19" y2="12" />
        </svg>
      </button>

      {/* FAB Options Selection Modal */}
      {showAddSelector && (
        <div className="modal-overlay" onClick={() => setShowAddSelector(false)}>
          <div className="modal-content animate-scale-in" onClick={e => e.stopPropagation()} style={{ maxWidth: '320px' }}>
            <h3 style={{ fontSize: '16px', fontWeight: 700, marginBottom: '16px', textAlign: 'center' }}>Choose Log Type</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <button
                onClick={() => {
                  setShowAddSelector(false);
                  setShowMealModal(true);
                }}
                className="btn btn-primary"
                style={{ background: 'linear-gradient(135deg, #00f2fe, #4facfe)' }}
              >
                🍳 Log Meal
              </button>
              <button
                onClick={() => {
                  setShowAddSelector(false);
                  setShowWorkoutModal(true);
                }}
                className="btn btn-primary"
                style={{ background: 'linear-gradient(135deg, #8b5cf6, #a78bfa)', color: '#fff' }}
              >
                🏋️ Log Exercise
              </button>
              <button onClick={() => setShowAddSelector(false)} className="btn btn-secondary">
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      {/* --- ADD MEAL MODAL --- */}
      {showMealModal && (
        <div className="modal-overlay" onClick={() => setShowMealModal(false)}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <h3 style={{ fontSize: '18px', fontWeight: 700, marginBottom: '16px' }}>Log a Meal</h3>
            
            <form onSubmit={handleAddMeal} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              
              <div className="input-group">
                <span className="input-label">Meal Category</span>
                <div className="toggle-group">
                  {['Breakfast', 'Lunch', 'Dinner', 'Snack'].map(c => (
                    <button
                      key={c}
                      type="button"
                      onClick={() => setMealCategory(c)}
                      className={`toggle-btn ${mealCategory === c ? 'active' : ''}`}
                      style={{ fontSize: '12px', padding: '8px' }}
                    >
                      {c}
                    </button>
                  ))}
                </div>
              </div>

              {/* Favorites / Recents Shortcuts */}
              {recentMeals.length > 0 && !isCustomFood && (
                <div style={{ textAlign: 'left' }}>
                  <span className="input-label" style={{ fontSize: '11px', display: 'block', marginBottom: '6px' }}>Recent Logs</span>
                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
                    {recentMeals.map((rm, idx) => (
                      <button
                        key={idx}
                        type="button"
                        onClick={() => {
                          setSelectedFood(rm);
                          setFoodSearch(rm.name);
                        }}
                        style={{
                          background: '#12141c',
                          border: '1px solid #2b3042',
                          borderRadius: '6px',
                          padding: '4px 8px',
                          color: '#e5e7eb',
                          fontSize: '11px',
                          cursor: 'pointer'
                        }}
                      >
                        + {rm.name}
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {/* Search or Custom Toggle */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span className="input-label">Food Details</span>
                <button
                  type="button"
                  onClick={() => setIsCustomFood(!isCustomFood)}
                  style={{ background: 'none', border: 'none', color: '#00f2fe', fontSize: '12px', cursor: 'pointer', fontWeight: 600 }}
                >
                  {isCustomFood ? 'Search Database' : 'Enter Custom Food'}
                </button>
              </div>

              {!isCustomFood ? (
                <div className="input-group" style={{ position: 'relative' }}>
                  <input
                    type="text"
                    value={foodSearch}
                    onChange={e => {
                      setFoodSearch(e.target.value);
                      setSelectedFood(null);
                    }}
                    placeholder="Search e.g. rajma, oatmeal, egg..."
                    className="input-field"
                    required={!selectedFood}
                  />
                  {/* Autocomplete Dropdown */}
                  {filteredFoods.length > 0 && !selectedFood && (
                    <div style={{
                      position: 'absolute',
                      top: '100%',
                      left: 0,
                      right: 0,
                      background: '#1a1d28',
                      border: '1px solid #2b3042',
                      borderRadius: '8px',
                      maxHeight: '160px',
                      overflowY: 'auto',
                      zIndex: 10,
                      boxShadow: '0 8px 16px rgba(0,0,0,0.5)'
                    }}>
                      {filteredFoods.map(food => (
                        <div
                          key={food.id}
                          onClick={() => {
                            setSelectedFood(food);
                            setFoodSearch(food.name);
                          }}
                          style={{
                            padding: '10px 16px',
                            borderBottom: '1px solid #12141c',
                            cursor: 'pointer',
                            textAlign: 'left',
                            fontSize: '14px'
                          }}
                          className="food-option"
                        >
                          <span style={{ fontWeight: 600 }}>{food.name}</span>
                          <span style={{ float: 'right', fontSize: '12px', color: '#9ca3af' }}>
                            {food.calories}kcal / {food.servingUnit}
                          </span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  <input
                    type="text"
                    placeholder="Food Name"
                    value={customFoodName}
                    onChange={e => setCustomFoodName(e.target.value)}
                    className="input-field"
                    required
                  />
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                    <input
                      type="number"
                      placeholder="Calories (kcal)"
                      value={customCalories}
                      onChange={e => setCustomCalories(e.target.value)}
                      className="input-field"
                      required
                    />
                    <input
                      type="number"
                      placeholder="Protein (g)"
                      value={customProtein}
                      onChange={e => setCustomProtein(e.target.value)}
                      className="input-field"
                    />
                    <input
                      type="number"
                      placeholder="Carbohydrates (g)"
                      value={customCarbs}
                      onChange={e => setCustomCarbs(e.target.value)}
                      className="input-field"
                    />
                    <input
                      type="number"
                      placeholder="Fats (g)"
                      value={customFat}
                      onChange={e => setCustomFat(e.target.value)}
                      className="input-field"
                    />
                  </div>
                </div>
              )}

              {/* Portion Weight */}
              <div className="input-group">
                <label className="input-label">Portion Size (g)</label>
                <input
                  type="number"
                  min="1"
                  value={mealPortion}
                  onChange={e => setMealPortion(Math.max(1, parseInt(e.target.value) || 0))}
                  className="input-field"
                  required
                />
              </div>

              {/* Live Preview of nutrition */}
              {(selectedFood || isCustomFood) && (
                <div style={{ background: '#12141c', padding: '12px 16px', borderRadius: '8px', fontSize: '13px', textAlign: 'left', border: '1px solid #2b3042' }}>
                  <span style={{ color: '#00f2fe', fontWeight: 600, display: 'block', marginBottom: '4px' }}>Log Preview:</span>
                  {isCustomFood ? (
                    <div>
                      Calories: <strong>{parseInt(customCalories) || 0} kcal</strong> |
                      P: <strong>{parseInt(customProtein) || 0}g</strong> |
                      C: <strong>{parseInt(customCarbs) || 0}g</strong> |
                      F: <strong>{parseInt(customFat) || 0}g</strong>
                    </div>
                  ) : (
                    <div>
                      {selectedFood.name} ({mealPortion}g): 
                      <strong style={{ color: '#fff' }}> {Math.round(selectedFood.calories * (mealPortion/100))} kcal</strong>
                      <div style={{ color: '#9ca3af', fontSize: '11px', marginTop: '2px' }}>
                        P: {Math.round(selectedFood.protein * (mealPortion/100))}g | 
                        C: {Math.round(selectedFood.carbs * (mealPortion/100))}g | 
                        F: {Math.round(selectedFood.fat * (mealPortion/100))}g
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* Action Buttons */}
              <div style={{ display: 'flex', gap: '12px' }}>
                <button type="button" onClick={() => setShowMealModal(false)} className="btn btn-secondary" style={{ flex: 1 }}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary" style={{ flex: 2 }}>
                  Log Food
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* --- ADD WORKOUT MODAL --- */}
      {showWorkoutModal && (
        <div className="modal-overlay" onClick={() => setShowWorkoutModal(false)}>
          <div className="modal-content" onClick={e => e.stopPropagation()} style={{ maxWidth: '440px' }}>
            <h3 style={{ fontSize: '18px', fontWeight: 700, marginBottom: '16px' }}>Log Exercise</h3>

            <form onSubmit={handleAddWorkout} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              
              {/* Custom or database exercise */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span className="input-label">Exercise Name</span>
                <button
                  type="button"
                  onClick={() => setIsCustomExercise(!isCustomExercise)}
                  style={{ background: 'none', border: 'none', color: '#8b5cf6', fontSize: '12px', cursor: 'pointer', fontWeight: 600 }}
                >
                  {isCustomExercise ? 'Select standard' : 'Create Custom'}
                </button>
              </div>

              {!isCustomExercise ? (
                <div className="input-group" style={{ position: 'relative' }}>
                  <input
                    type="text"
                    value={exerciseSearch}
                    onChange={e => {
                      setExerciseSearch(e.target.value);
                      setSelectedExercise(null);
                    }}
                    placeholder="Search Bench Press, Squat, Running..."
                    className="input-field"
                    required={!selectedExercise}
                  />
                  {filteredExercises.length > 0 && !selectedExercise && (
                    <div style={{
                      position: 'absolute',
                      top: '100%',
                      left: 0,
                      right: 0,
                      background: '#1a1d28',
                      border: '1px solid #2b3042',
                      borderRadius: '8px',
                      maxHeight: '160px',
                      overflowY: 'auto',
                      zIndex: 10
                    }}>
                      {filteredExercises.map(ex => (
                        <div
                          key={ex.id}
                          onClick={() => {
                            setSelectedExercise(ex);
                            setExerciseSearch(ex.name);
                            loadExerciseHistory(ex.name);
                          }}
                          style={{
                            padding: '10px 16px',
                            borderBottom: '1px solid #12141c',
                            cursor: 'pointer',
                            textAlign: 'left',
                            fontSize: '14px'
                          }}
                        >
                          <span style={{ fontWeight: 600 }}>{ex.name}</span>
                          <span style={{ float: 'right', fontSize: '11px', color: '#8b5cf6', background: 'rgba(139,92,246,0.1)', padding: '2px 6px', borderRadius: '4px' }}>
                            {ex.primaryMuscle}
                          </span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              ) : (
                <input
                  type="text"
                  placeholder="Custom Exercise Name"
                  value={customExerciseName}
                  onChange={e => {
                    setCustomExerciseName(e.target.value);
                    loadExerciseHistory(e.target.value);
                  }}
                  className="input-field"
                  required
                />
              )}

              {/* Progressive Overload Info Panel */}
              <div style={{
                background: '#12141c',
                border: '1px solid #2b3042',
                borderRadius: '8px',
                padding: '10px 14px',
                fontSize: '12px',
                textAlign: 'left'
              }}>
                <span style={{ color: '#8b5cf6', fontWeight: 600, display: 'block', marginBottom: '2px' }}>Progressive Overload Target:</span>
                <span style={{ color: '#9ca3af' }}>{prevSessionText}</span>
              </div>

              {/* Set By Set Inputs */}
              <div style={{ textAlign: 'left' }}>
                <span className="input-label" style={{ display: 'block', marginBottom: '10px' }}>Sets</span>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  {workoutSets.map((set, index) => (
                    <div key={index} style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span style={{ fontSize: '13px', fontWeight: 600, width: '40px', color: '#9ca3af' }}>Set {index + 1}</span>
                      
                      <input
                        type="number"
                        placeholder="Weight (kg)"
                        value={set.weight}
                        onChange={e => handleSetChange(index, 'weight', e.target.value)}
                        className="input-field"
                        style={{ padding: '8px 12px', fontSize: '14px' }}
                        required
                      />
                      
                      <input
                        type="number"
                        placeholder="Reps"
                        value={set.reps}
                        onChange={e => handleSetChange(index, 'reps', e.target.value)}
                        className="input-field"
                        style={{ padding: '8px 12px', fontSize: '14px' }}
                        required
                      />

                      <button
                        type="button"
                        onClick={() => handleRemoveSet(index)}
                        disabled={workoutSets.length === 1}
                        style={{
                          background: 'none',
                          border: 'none',
                          color: '#ef4444',
                          cursor: 'pointer',
                          padding: '4px'
                        }}
                      >
                        ✕
                      </button>
                    </div>
                  ))}
                </div>

                <button
                  type="button"
                  onClick={handleAddSet}
                  className="btn btn-secondary"
                  style={{ padding: '6px 12px', fontSize: '12px', width: 'auto', marginTop: '10px' }}
                >
                  + Add Set
                </button>
              </div>

              {/* Action Buttons */}
              <div style={{ display: 'flex', gap: '12px', marginTop: '8px' }}>
                <button type="button" onClick={() => setShowWorkoutModal(false)} className="btn btn-secondary" style={{ flex: 1 }}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary" style={{ flex: 2, background: 'linear-gradient(135deg, #8b5cf6, #a78bfa)', color: '#fff' }}>
                  Log Exercise
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <style dangerouslySetInnerHTML={{__html: `
        .food-option:hover {
          background-color: #222634 !important;
        }
      `}} />
    </div>
  );
}
