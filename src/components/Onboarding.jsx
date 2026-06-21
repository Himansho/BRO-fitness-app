import React, { useState } from 'react';
import { generateSaltHex, deriveKeyFromPin, setSessionKey } from '../utils/crypto';
import { db } from '../utils/db';

export default function Onboarding({ onComplete }) {
  const [step, setStep] = useState(1);
  const [unitSystem, setUnitSystem] = useState('metric'); // metric or imperial
  const [gender, setGender] = useState('male');
  const [age, setAge] = useState(25);
  const [weight, setWeight] = useState(70); // kg or lbs
  const [height, setHeight] = useState(170); // cm or inches
  const [activityLevel, setActivityLevel] = useState('moderate');
  const [goal, setGoal] = useState('lose');
  
  const [pin, setPin] = useState('');
  const [confirmPin, setConfirmPin] = useState('');
  const [pinError, setPinError] = useState('');
  const [loading, setLoading] = useState(false);

  // Mifflin-St Jeor BMR & TDEE Calculations
  const calculateTargets = () => {
    let w = parseFloat(weight);
    let h = parseFloat(height);

    // Convert to metric internally if user entered imperial
    if (unitSystem === 'imperial') {
      w = w * 0.45359237; // lbs to kg
      h = h * 2.54; // inches to cm
    }

    // BMI
    const heightInMeters = h / 100;
    const bmi = w / (heightInMeters * heightInMeters);

    // BMR
    let bmr = 0;
    if (gender === 'male') {
      bmr = 10 * w + 6.25 * h - 5 * age + 5;
    } else {
      bmr = 10 * w + 6.25 * h - 5 * age - 161;
    }

    // TDEE multipliers
    const multipliers = {
      sedentary: 1.2,
      light: 1.375,
      moderate: 1.55,
      active: 1.725
    };
    const tdee = bmr * multipliers[activityLevel];

    // Daily Calorie Budget based on Goal
    let calorieBudget = Math.round(tdee);
    if (goal === 'lose') {
      calorieBudget = Math.round(tdee - 500);
    } else if (goal === 'build') {
      calorieBudget = Math.round(tdee + 300);
    }

    // Macros
    // Protein: 1.8g per kg bodyweight
    const proteinGrams = Math.round(w * 1.8);
    const proteinCalories = proteinGrams * 4;

    // Fats: 25% of calories
    const fatCalories = calorieBudget * 0.25;
    const fatGrams = Math.round(fatCalories / 9);

    // Carbs: remaining calories
    const carbCalories = calorieBudget - proteinCalories - fatCalories;
    const carbGrams = Math.round(Math.max(carbCalories / 4, 50));

    return {
      bmi: parseFloat(bmi.toFixed(1)),
      bmr: Math.round(bmr),
      tdee: Math.round(tdee),
      calorieBudget,
      protein: proteinGrams,
      carbs: carbGrams,
      fat: fatGrams
    };
  };

  const targets = calculateTargets();

  const handleNextStep = () => {
    setStep(prev => prev + 1);
  };

  const handlePrevStep = () => {
    setStep(prev => prev - 1);
  };

  const handleCompleteSetup = async () => {
    if (pin.length !== 4 || isNaN(pin)) {
      setPinError('PIN must be exactly 4 digits.');
      return;
    }
    if (pin !== confirmPin) {
      setPinError('PINs do not match.');
      return;
    }

    setLoading(true);
    setPinError('');

    try {
      // 1. Generate salt
      const salt = generateSaltHex();
      
      // 2. Derive key from PIN and salt
      const cryptoKey = await deriveKeyFromPin(pin, salt);
      
      // 3. Save salt in plain storage (localStorage)
      localStorage.setItem('user_db_salt', salt);
      
      // 4. Set session key in memory
      setSessionKey(cryptoKey);
      
      // 5. Build user profile object
      const profileData = {
        unitSystem,
        gender,
        age,
        weight: parseFloat(weight),
        height: parseFloat(height),
        activityLevel,
        goal,
        bmi: targets.bmi,
        calorieBudget: targets.calorieBudget,
        macros: {
          protein: targets.protein,
          carbs: targets.carbs,
          fat: targets.fat
        },
        setupDate: new Date().toISOString().split('T')[0]
      };

      // 6. Save encrypted profile in database
      await db.saveProfile(profileData);
      
      // 7. Complete onboarding
      onComplete(profileData);
    } catch (err) {
      setPinError('Failed to initialize database: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      minHeight: '100vh',
      backgroundColor: '#0a0b0e',
      padding: '24px',
      color: '#f3f4f6',
      justifyContent: 'center',
      alignItems: 'center'
    }}>
      <div style={{
        maxWidth: '480px',
        width: '100%',
        background: '#12141c',
        border: '1px solid #2b3042',
        borderRadius: '24px',
        padding: '32px',
        boxShadow: '0 8px 32px rgba(0, 0, 0, 0.4)',
        animation: 'scaleIn 0.3s ease'
      }}>
        {/* Header Progress */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
          <h2 style={{ fontSize: '20px', fontWeight: 700 }}>Profile Creation</h2>
          <span style={{ fontSize: '13px', color: '#9ca3af', fontWeight: 600 }}>Step {step} of 3</span>
        </div>
        <div style={{ display: 'flex', gap: '8px', marginBottom: '32px', height: '4px' }}>
          {[1, 2, 3].map(s => (
            <div key={s} style={{
              flex: 1,
              backgroundColor: step >= s ? '#00f2fe' : '#2b3042',
              borderRadius: '2px',
              transition: 'background-color 0.3s'
            }} />
          ))}
        </div>

        {/* STEP 1: Units & Demographics */}
        {step === 1 && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div className="input-group">
              <span className="input-label">Unit Preference</span>
              <div className="toggle-group">
                <button
                  onClick={() => {
                    setUnitSystem('metric');
                    // Reset defaults
                    setWeight(70);
                    setHeight(170);
                  }}
                  className={`toggle-btn ${unitSystem === 'metric' ? 'active' : ''}`}
                >
                  Metric (kg/cm)
                </button>
                <button
                  onClick={() => {
                    setUnitSystem('imperial');
                    // Reset defaults
                    setWeight(150);
                    setHeight(68);
                  }}
                  className={`toggle-btn ${unitSystem === 'imperial' ? 'active' : ''}`}
                >
                  Imperial (lb/in)
                </button>
              </div>
            </div>

            <div className="input-group">
              <span className="input-label">Biological Gender</span>
              <div className="toggle-group">
                <button
                  onClick={() => setGender('male')}
                  className={`toggle-btn ${gender === 'male' ? 'active' : ''}`}
                >
                  Male
                </button>
                <button
                  onClick={() => setGender('female')}
                  className={`toggle-btn ${gender === 'female' ? 'active' : ''}`}
                >
                  Female
                </button>
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Age (Years)</label>
              <input
                type="number"
                min="10"
                max="100"
                value={age}
                onChange={e => setAge(Math.max(10, parseInt(e.target.value) || 0))}
                className="input-field"
              />
            </div>

            <button onClick={handleNextStep} className="btn btn-primary" style={{ marginTop: '16px' }}>
              Continue
            </button>
          </div>
        )}

        {/* STEP 2: Body Stats & Goals */}
        {step === 2 && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div className="input-group">
                <label className="input-label">Weight ({unitSystem === 'metric' ? 'kg' : 'lbs'})</label>
                <input
                  type="number"
                  step="0.1"
                  min="20"
                  value={weight}
                  onChange={e => setWeight(parseFloat(e.target.value) || 0)}
                  className="input-field"
                />
              </div>
              <div className="input-group">
                <label className="input-label">Height ({unitSystem === 'metric' ? 'cm' : 'inches'})</label>
                <input
                  type="number"
                  min="50"
                  value={height}
                  onChange={e => setHeight(parseFloat(e.target.value) || 0)}
                  className="input-field"
                />
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Activity Level</label>
              <select
                value={activityLevel}
                onChange={e => setActivityLevel(e.target.value)}
                className="input-field select-field"
              >
                <option value="sedentary">Sedentary (Little/no exercise)</option>
                <option value="light">Lightly Active (1-3 days/wk)</option>
                <option value="moderate">Moderately Active (3-5 days/wk)</option>
                <option value="active">Very Active (6-7 days/wk)</option>
              </select>
            </div>

            <div className="input-group">
              <label className="input-label">Fitness Goal</label>
              <select
                value={goal}
                onChange={e => setGoal(e.target.value)}
                className="input-field select-field"
              >
                <option value="lose">Weight Loss (Caloric Deficit)</option>
                <option value="maintain">Maintenance (Stay Same Weight)</option>
                <option value="build">Build Muscle (Caloric Surplus)</option>
              </select>
            </div>

            {/* Calculated Preview Panel */}
            <div style={{
              background: '#1a1d28',
              border: '1px solid #2b3042',
              borderRadius: '12px',
              padding: '16px',
              textAlign: 'left'
            }}>
              <h4 style={{ fontSize: '14px', color: '#00f2fe', marginBottom: '12px', fontWeight: 600 }}>Estimated Baseline Calculations</h4>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', fontSize: '13px' }}>
                <div>BMI: <strong style={{ color: '#fff' }}>{targets.bmi}</strong></div>
                <div>Calorie Goal: <strong style={{ color: '#fff' }}>{targets.calorieBudget} kcal</strong></div>
                <div>Protein: <strong style={{ color: '#fff' }}>{targets.protein}g</strong></div>
                <div>Carbs: <strong style={{ color: '#fff' }}>{targets.carbs}g</strong></div>
                <div>Fats: <strong style={{ color: '#fff' }}>{targets.fat}g</strong></div>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '12px', marginTop: '16px' }}>
              <button onClick={handlePrevStep} className="btn btn-secondary" style={{ flex: 1 }}>
                Back
              </button>
              <button onClick={handleNextStep} className="btn btn-primary" style={{ flex: 2 }}>
                Continue
              </button>
            </div>
          </div>
        )}

        {/* STEP 3: Cryptographic PIN Security */}
        {step === 3 && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div style={{ textAlign: 'left' }}>
              <h3 style={{ fontSize: '16px', fontWeight: 600, color: '#fff', marginBottom: '8px' }}>Setup Security PIN</h3>
              <p style={{ color: '#9ca3af', fontSize: '13px', lineHeight: 1.4 }}>
                This application stores all logs, metrics, and progress photos locally in an encrypted database. 
                Enter a 4-digit PIN to secure your data. This PIN is never uploaded to any cloud and cannot be recovered if lost.
              </p>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div className="input-group">
                <label className="input-label">4-Digit PIN</label>
                <input
                  type="password"
                  maxLength="4"
                  pattern="[0-9]*"
                  inputMode="numeric"
                  value={pin}
                  onChange={e => setPin(e.target.value.replace(/\D/g, '').slice(0, 4))}
                  className="input-field"
                  placeholder="••••"
                  style={{ textAlign: 'center', fontSize: '20px', letterSpacing: '8px' }}
                />
              </div>
              <div className="input-group">
                <label className="input-label">Confirm PIN</label>
                <input
                  type="password"
                  maxLength="4"
                  pattern="[0-9]*"
                  inputMode="numeric"
                  value={confirmPin}
                  onChange={e => setConfirmPin(e.target.value.replace(/\D/g, '').slice(0, 4))}
                  className="input-field"
                  placeholder="••••"
                  style={{ textAlign: 'center', fontSize: '20px', letterSpacing: '8px' }}
                />
              </div>
            </div>

            {pinError && (
              <span style={{ color: '#ef4444', fontSize: '13px', fontWeight: 500 }}>
                {pinError}
              </span>
            )}

            <div style={{ display: 'flex', gap: '12px', marginTop: '16px' }}>
              <button onClick={handlePrevStep} className="btn btn-secondary" style={{ flex: 1 }} disabled={loading}>
                Back
              </button>
              <button 
                onClick={handleCompleteSetup} 
                className="btn btn-primary" 
                style={{ flex: 2 }}
                disabled={loading || pin.length !== 4 || confirmPin.length !== 4}
              >
                {loading ? 'Initializing Database...' : 'Decrypt & Finish'}
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
