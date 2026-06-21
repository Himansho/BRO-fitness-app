import React, { useState, useEffect } from 'react';
import { db } from '../utils/db';

export default function Settings({ profile, onProfileUpdated, onLogUpdated }) {
  // Profile settings state
  const [unitSystem, setUnitSystem] = useState(profile.unitSystem);
  const [age, setAge] = useState(profile.age);
  const [weight, setWeight] = useState(profile.weight);
  const [height, setHeight] = useState(profile.height);
  const [activityLevel, setActivityLevel] = useState(profile.activityLevel);
  const [goal, setGoal] = useState(profile.goal);
  const [targetWeight, setTargetWeight] = useState(profile.targetWeight || profile.weight);
  const [saveSuccess, setSaveSuccess] = useState(false);

  // Reminders state
  const [reminders, setReminders] = useState([
    { id: 'r-1', time: '08:00', text: 'Drink a glass of water!', enabled: true },
    { id: 'r-2', time: '13:00', text: 'Log your lunch and nutrients.', enabled: true },
    { id: 'r-3', time: '18:00', text: 'Time for your evening workout / walk.', enabled: false },
    { id: 'r-4', time: '21:00', text: 'Log your evening weight.', enabled: false }
  ]);

  // Report State
  const [showReport, setShowReport] = useState(false);
  const [reportRange, setReportRange] = useState('7'); // 7 days or 30 days
  const [reportStats, setReportStats] = useState(null);

  useEffect(() => {
    // Load reminders from localStorage if they exist
    const savedReminders = localStorage.getItem('user_reminders');
    if (savedReminders) {
      setReminders(JSON.parse(savedReminders));
    }
  }, []);

  const saveReminders = (updatedReminders) => {
    setReminders(updatedReminders);
    localStorage.setItem('user_reminders', JSON.stringify(updatedReminders));
  };

  const handleToggleReminder = (id) => {
    const updated = reminders.map(r => r.id === id ? { ...r, enabled: !r.enabled } : r);
    saveReminders(updated);
  };

  const handleUpdateReminderText = (id, text) => {
    const updated = reminders.map(r => r.id === id ? { ...r, text } : r);
    saveReminders(updated);
  };

  const handleUpdateReminderTime = (id, time) => {
    const updated = reminders.map(r => r.id === id ? { ...r, time } : r);
    saveReminders(updated);
  };

  // Recalculate and Save Profile
  const handleSaveProfile = async (e) => {
    e.preventDefault();

    let w = parseFloat(weight);
    let h = parseFloat(height);

    if (unitSystem === 'imperial') {
      w = w * 0.45359237; // lbs to kg
      h = h * 2.54; // inches to cm
    }

    const heightInMeters = h / 100;
    const bmi = parseFloat((w / (heightInMeters * heightInMeters)).toFixed(1));

    let bmr = 0;
    if (profile.gender === 'male') {
      bmr = 10 * w + 6.25 * h - 5 * age + 5;
    } else {
      bmr = 10 * w + 6.25 * h - 5 * age - 161;
    }

    const multipliers = {
      sedentary: 1.2,
      light: 1.375,
      moderate: 1.55,
      active: 1.725
    };
    const tdee = bmr * multipliers[activityLevel];

    let calorieBudget = Math.round(tdee);
    if (goal === 'lose') {
      calorieBudget = Math.round(tdee - 500);
    } else if (goal === 'build') {
      calorieBudget = Math.round(tdee + 300);
    }

    const proteinGrams = Math.round(w * 1.8);
    const proteinCalories = proteinGrams * 4;
    const fatCalories = calorieBudget * 0.25;
    const fatGrams = Math.round(fatCalories / 9);
    const carbCalories = calorieBudget - proteinCalories - fatCalories;
    const carbGrams = Math.round(Math.max(carbCalories / 4, 50));

    const updatedProfile = {
      ...profile,
      unitSystem,
      age: parseInt(age),
      weight: parseFloat(weight),
      height: parseFloat(height),
      activityLevel,
      goal,
      targetWeight: parseFloat(targetWeight),
      bmi,
      calorieBudget,
      macros: {
        protein: proteinGrams,
        carbs: carbGrams,
        fat: fatGrams
      }
    };

    try {
      await db.saveProfile(updatedProfile);
      onProfileUpdated(updatedProfile);
      setSaveSuccess(true);
      setTimeout(() => setSaveSuccess(false), 3000);
    } catch (err) {
      console.error(err);
      alert('Failed to save settings: ' + err.message);
    }
  };

  // 100% Offline Backup Export
  const handleExportBackup = async () => {
    try {
      const backupData = await db.exportBackupData();
      const salt = localStorage.getItem('user_db_salt');
      
      const fileData = {
        app: 'UltraPrivateFitnessJournal',
        version: 1,
        salt: salt,
        exportedAt: new Date().toISOString(),
        backup: backupData
      };

      const jsonStr = JSON.stringify(fileData, null, 2);
      const blob = new Blob([jsonStr], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      
      const a = document.createElement('a');
      a.href = url;
      a.download = `offline_fitness_backup_${new Date().toISOString().split('T')[0]}.json`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    } catch (err) {
      console.error(err);
      alert('Failed to export backup: ' + err.message);
    }
  };

  // 100% Offline Backup Restore
  const handleImportBackup = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    if (!window.confirm('Restoring will replace all current data. Make sure you know your backup file\'s PIN. Proceed?')) {
      return;
    }

    const reader = new FileReader();
    reader.onload = async (event) => {
      try {
        const fileData = JSON.parse(event.target.result);
        
        if (fileData.app !== 'UltraPrivateFitnessJournal' || !fileData.backup) {
          alert('Invalid backup file format.');
          return;
        }

        // Restore salt in LocalStorage
        if (fileData.salt) {
          localStorage.setItem('user_db_salt', fileData.salt);
        }

        // Restore encrypted stores in IndexedDB
        await db.importBackupData(fileData.backup);
        
        alert('Encrypted database restored successfully. Please log in again using the PIN of the restored backup.');
        
        // Clear session key and trigger reload (wipes key and shows lock screen)
        window.location.reload();
      } catch (err) {
        console.error(err);
        alert('Failed to import backup: ' + err.message);
      }
    };
    reader.readAsText(file);
  };

  // Compile stats for PDF report
  const generateReportData = async () => {
    try {
      const daysCount = parseInt(reportRange);
      const today = new Date();
      const logs = [];
      let totalSteps = 0;
      let totalCalsIn = 0;
      let totalCalsOut = 0;
      let loggedDays = 0;

      for (let i = 0; i < daysCount; i++) {
        const d = new Date(today);
        d.setDate(today.getDate() - i);
        const dateStr = d.toISOString().split('T')[0];
        
        const dayLog = await db.getDailyLog(dateStr);
        if (dayLog) {
          const calIn = dayLog.meals.reduce((sum, m) => sum + m.calories, 0);
          totalCalsIn += calIn;
          totalCalsOut += dayLog.activeCalories;
          totalSteps += dayLog.steps;
          
          if (calIn > 0 || dayLog.steps > 0 || dayLog.workouts.length > 0) {
            loggedDays++;
          }
          
          logs.push({
            date: dateStr,
            meals: dayLog.meals,
            workouts: dayLog.workouts,
            steps: dayLog.steps,
            water: dayLog.water,
            activeCalories: dayLog.activeCalories
          });
        }
      }

      // Fetch progress photos within range
      const allPhotos = await db.getPhotos();
      const rangePhotos = allPhotos.filter(p => {
        const diffTime = Math.abs(today - new Date(p.date));
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        return diffDays <= daysCount;
      });

      setReportStats({
        range: daysCount,
        generatedAt: new Date().toLocaleDateString(),
        avgSteps: loggedDays > 0 ? Math.round(totalSteps / loggedDays) : 0,
        avgCalsIn: loggedDays > 0 ? Math.round(totalCalsIn / loggedDays) : 0,
        avgCalsOut: loggedDays > 0 ? Math.round(totalCalsOut / loggedDays) : 0,
        logs: logs.filter(l => l.meals.length > 0 || l.workouts.length > 0),
        photos: rangePhotos
      });

      setShowReport(true);
    } catch (err) {
      console.error(err);
      alert('Failed to generate report stats: ' + err.message);
    }
  };

  const triggerPrintReport = () => {
    window.print();
  };

  return (
    <div className="tab-content animate-fade-in" style={{ paddingBottom: '80px', textAlign: 'left' }}>
      
      {/* 1. EDIT PROFILE / TARGETS */}
      <div className="card">
        <h3 style={{ fontSize: '16px', fontWeight: 700, marginBottom: '16px', color: '#fff' }}>Profile & Goal Parameters</h3>
        <form onSubmit={handleSaveProfile} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          
          <div className="toggle-group">
            <button
              type="button"
              onClick={() => setUnitSystem('metric')}
              className={`toggle-btn ${unitSystem === 'metric' ? 'active' : ''}`}
            >
              Metric (kg/cm)
            </button>
            <button
              type="button"
              onClick={() => setUnitSystem('imperial')}
              className={`toggle-btn ${unitSystem === 'imperial' ? 'active' : ''}`}
            >
              Imperial (lb/in)
            </button>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
            <div className="input-group">
              <label className="input-label">Age</label>
              <input
                type="number"
                value={age}
                onChange={e => setAge(e.target.value)}
                className="input-field"
                required
              />
            </div>
            <div className="input-group">
              <label className="input-label">Height ({unitSystem === 'metric' ? 'cm' : 'in'})</label>
              <input
                type="number"
                value={height}
                onChange={e => setHeight(e.target.value)}
                className="input-field"
                required
              />
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
            <div className="input-group">
              <label className="input-label">Weight ({unitSystem === 'metric' ? 'kg' : 'lbs'})</label>
              <input
                type="number"
                step="0.1"
                value={weight}
                onChange={e => setWeight(e.target.value)}
                className="input-field"
                required
              />
            </div>
            <div className="input-group">
              <label className="input-label">Target Weight</label>
              <input
                type="number"
                step="0.1"
                value={targetWeight}
                onChange={e => setTargetWeight(e.target.value)}
                className="input-field"
                required
              />
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
            <div className="input-group">
              <label className="input-label">Activity Level</label>
              <select
                value={activityLevel}
                onChange={e => setActivityLevel(e.target.value)}
                className="input-field select-field"
              >
                <option value="sedentary">Sedentary</option>
                <option value="light">Lightly Active</option>
                <option value="moderate">Moderately Active</option>
                <option value="active">Very Active</option>
              </select>
            </div>
            <div className="input-group">
              <label className="input-label">Goal</label>
              <select
                value={goal}
                onChange={e => setGoal(e.target.value)}
                className="input-field select-field"
              >
                <option value="lose">Lose Weight</option>
                <option value="maintain">Maintain</option>
                <option value="build">Build Muscle</option>
              </select>
            </div>
          </div>

          {saveSuccess && (
            <span style={{ color: '#10b981', fontSize: '13px', fontWeight: 600 }}>
              ✔ Profile updated and targets recalculated!
            </span>
          )}

          <button type="submit" className="btn btn-primary">
            Save Profile & Update Targets
          </button>
        </form>
      </div>

      {/* 2. LOCAL OFFLINE REMINDERS */}
      <div className="card">
        <h3 style={{ fontSize: '16px', fontWeight: 700, marginBottom: '8px', color: '#fff' }}>Local Reminders</h3>
        <p style={{ color: '#9ca3af', fontSize: '12px', marginBottom: '16px', lineHeight: 1.4 }}>
          Enable scheduled daily triggers. Reminders check local browser time and trigger in-app banners.
        </p>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          {reminders.map(rem => (
            <div
              key={rem.id}
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '12px',
                background: '#12141c',
                border: '1px solid #2b3042',
                borderRadius: '8px',
                gap: '8px'
              }}
            >
              <div style={{ display: 'flex', gap: '8px', flex: 1, alignItems: 'center' }}>
                <input
                  type="time"
                  value={rem.time}
                  onChange={e => handleUpdateReminderTime(rem.id, e.target.value)}
                  style={{
                    background: '#1a1d28',
                    border: '1px solid #2b3042',
                    color: '#fff',
                    padding: '4px',
                    borderRadius: '4px',
                    fontFamily: 'Outfit',
                    fontSize: '13px'
                  }}
                />
                <input
                  type="text"
                  value={rem.text}
                  onChange={e => handleUpdateReminderText(rem.id, e.target.value)}
                  style={{
                    background: 'none',
                    border: 'none',
                    borderBottom: '1px solid #2b3042',
                    color: rem.enabled ? '#fff' : '#6b7280',
                    padding: '2px 4px',
                    fontSize: '13px',
                    flex: 1,
                    outline: 'none'
                  }}
                />
              </div>

              {/* Toggle Switch */}
              <button
                onClick={() => handleToggleReminder(rem.id)}
                style={{
                  background: rem.enabled ? 'rgba(0,242,254,0.1)' : 'rgba(255,255,255,0.05)',
                  border: `1px solid ${rem.enabled ? '#00f2fe' : '#2b3042'}`,
                  borderRadius: '6px',
                  padding: '4px 10px',
                  color: rem.enabled ? '#00f2fe' : '#6b7280',
                  fontSize: '11px',
                  cursor: 'pointer',
                  fontWeight: 600
                }}
              >
                {rem.enabled ? 'ACTIVE' : 'OFF'}
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* 3. REPORT GENERATOR (PDF SUMMARY) */}
      <div className="card">
        <h3 style={{ fontSize: '16px', fontWeight: 700, marginBottom: '8px', color: '#fff' }}>Transformation PDF Reports</h3>
        <p style={{ color: '#9ca3af', fontSize: '12px', marginBottom: '16px' }}>
          Generate a summary report of your stats, workouts, and progress photos to print or save offline.
        </p>

        <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
          <select
            value={reportRange}
            onChange={e => setReportRange(e.target.value)}
            className="input-field select-field"
            style={{ width: '120px', padding: '10px 32px 10px 12px', margin: 0 }}
          >
            <option value="7">Last 7 Days</option>
            <option value="30">Last 30 Days</option>
          </select>

          <button
            onClick={generateReportData}
            className="btn btn-primary"
            style={{ flex: 1 }}
          >
            Generate Progress Report
          </button>
        </div>
      </div>

      {/* 4. BACKUP & RESTORE DATA */}
      <div className="card" style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
        <h3 style={{ fontSize: '16px', fontWeight: 700, color: '#fff' }}>Database Backup & Migration</h3>
        
        <p style={{ color: '#9ca3af', fontSize: '12px', lineHeight: 1.4 }}>
          Export your entire encrypted journal (logs, profile, photos) as a single secure JSON file. 
          You can import this file on any device to restore your database. Access requires the same PIN used during export.
        </p>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
          <button
            onClick={handleExportBackup}
            className="btn btn-secondary"
            style={{ borderColor: 'rgba(0, 242, 254, 0.3)' }}
          >
            📥 Export Backup
          </button>

          <label
            className="btn btn-secondary"
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer'
            }}
          >
            📤 Restore Backup
            <input
              type="file"
              accept=".json"
              onChange={handleImportBackup}
              style={{ display: 'none' }}
            />
          </label>
        </div>
      </div>

      {/* --- PRINTABLE REPORT MODAL/CONTAINER --- */}
      {showReport && reportStats && (
        <div className="modal-overlay report-print-overlay" onClick={() => setShowReport(false)}>
          <div 
            className="modal-content print-report-container" 
            onClick={e => e.stopPropagation()}
            style={{ maxWidth: '700px', width: '100%' }}
          >
            {/* Print Header Actions (hidden during print) */}
            <div className="no-print" style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '24px', borderBottom: '1px solid #2b3042', paddingBottom: '12px' }}>
              <span style={{ fontWeight: 600 }}>Report Preview</span>
              <div style={{ display: 'flex', gap: '8px' }}>
                <button onClick={triggerPrintReport} className="btn btn-primary" style={{ width: 'auto', padding: '6px 16px', fontSize: '13px' }}>
                  🖨 Save PDF / Print
                </button>
                <button onClick={() => setShowReport(false)} className="btn btn-secondary" style={{ width: 'auto', padding: '6px 16px', fontSize: '13px' }}>
                  Close
                </button>
              </div>
            </div>

            {/* Core Printable Report Layout */}
            <div id="printable-report" style={{ color: '#000', backgroundColor: '#fff', padding: '32px', borderRadius: '8px', fontFamily: 'system-ui, sans-serif', textAlign: 'left' }}>
              
              {/* Header */}
              <div style={{ borderBottom: '2px solid #000', paddingBottom: '16px', marginBottom: '24px' }}>
                <h1 style={{ fontSize: '28px', color: '#000', margin: 0, fontWeight: 700 }}>OFFLINE PROGRESS REPORT</h1>
                <span style={{ fontSize: '13px', color: '#666' }}>Generated on {reportStats.generatedAt} • Range: Last {reportStats.range} Days</span>
              </div>

              {/* Profile details */}
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '24px', marginBottom: '24px', fontSize: '14px' }}>
                <div>
                  <h3 style={{ fontSize: '14px', borderBottom: '1px solid #ddd', paddingBottom: '4px', color: '#000' }}>User Profile</h3>
                  <div style={{ marginTop: '8px' }}>Height: <strong>{profile.height} {profile.unitSystem === 'metric' ? 'cm' : 'in'}</strong></div>
                  <div>Current Weight: <strong>{profile.weight} {profile.unitSystem === 'metric' ? 'kg' : 'lbs'}</strong></div>
                  <div>Goal Weight: <strong>{profile.targetWeight || '-'} {profile.unitSystem === 'metric' ? 'kg' : 'lbs'}</strong></div>
                  <div>BMI: <strong>{profile.bmi}</strong></div>
                </div>
                <div>
                  <h3 style={{ fontSize: '14px', borderBottom: '1px solid #ddd', paddingBottom: '4px', color: '#000' }}>Calculated Targets</h3>
                  <div style={{ marginTop: '8px' }}>Daily Calories: <strong>{profile.calorieBudget} kcal</strong></div>
                  <div>Protein Target: <strong>{profile.macros.protein}g</strong></div>
                  <div>Carbs Target: <strong>{profile.macros.carbs}g</strong></div>
                  <div>Fat Target: <strong>{profile.macros.fat}g</strong></div>
                </div>
              </div>

              {/* Summary Stats */}
              <div style={{
                background: '#f3f4f6',
                borderRadius: '8px',
                padding: '16px',
                display: 'grid',
                gridTemplateColumns: 'repeat(3, 1fr)',
                gap: '16px',
                marginBottom: '32px',
                textAlign: 'center'
              }}>
                <div>
                  <span style={{ fontSize: '11px', color: '#666', display: 'block', textTransform: 'uppercase' }}>Avg Steps</span>
                  <strong style={{ fontSize: '20px', color: '#000' }}>{reportStats.avgSteps.toLocaleString()}</strong>
                </div>
                <div>
                  <span style={{ fontSize: '11px', color: '#666', display: 'block', textTransform: 'uppercase' }}>Avg Cal Intake</span>
                  <strong style={{ fontSize: '20px', color: '#000' }}>{reportStats.avgCalsIn} kcal</strong>
                </div>
                <div>
                  <span style={{ fontSize: '11px', color: '#666', display: 'block', textTransform: 'uppercase' }}>Avg Watch Burn</span>
                  <strong style={{ fontSize: '20px', color: '#000' }}>{reportStats.avgCalsOut} kcal</strong>
                </div>
              </div>

              {/* Progress Photos section */}
              {reportStats.photos.length > 0 && (
                <div style={{ marginBottom: '32px' }}>
                  <h3 style={{ fontSize: '16px', borderBottom: '1px solid #000', paddingBottom: '6px', marginBottom: '16px', color: '#000' }}>Progress Photos</h3>
                  <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
                    {reportStats.photos.map(p => (
                      <div key={p.id} style={{ border: '1px solid #ccc', padding: '6px', borderRadius: '4px', width: '130px', textAlign: 'center' }}>
                        <img src={p.image} alt="Progress" style={{ width: '100%', height: '140px', objectFit: 'cover', borderRadius: '2px' }} />
                        <div style={{ fontSize: '11px', fontWeight: 600, marginTop: '6px', color: '#000', textTransform: 'capitalize' }}>{p.angle} view</div>
                        <div style={{ fontSize: '10px', color: '#666' }}>{p.date}</div>
                        {p.weight && <div style={{ fontSize: '10px', fontWeight: 'bold', color: '#000' }}>{p.weight} {profile.unitSystem === 'metric' ? 'kg' : 'lbs'}</div>}
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Logs Breakdown Table */}
              <div>
                <h3 style={{ fontSize: '16px', borderBottom: '1px solid #000', paddingBottom: '6px', marginBottom: '12px', color: '#000' }}>Daily Log Highlights</h3>
                
                {reportStats.logs.length === 0 ? (
                  <p style={{ fontSize: '12px', color: '#666' }}>No detailed logs in range.</p>
                ) : (
                  <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '12px' }}>
                    <thead>
                      <tr style={{ borderBottom: '1px solid #000', textAlign: 'left' }}>
                        <th style={{ padding: '6px 0' }}>Date</th>
                        <th>Calories Logged</th>
                        <th>Steps</th>
                        <th>Water</th>
                        <th>Logged Workouts</th>
                      </tr>
                    </thead>
                    <tbody>
                      {reportStats.logs.map(log => {
                        const totalCal = log.meals.reduce((sum, m) => sum + m.calories, 0);
                        const workoutsDesc = log.workouts.map(w => w.name).join(', ');
                        return (
                          <tr key={log.date} style={{ borderBottom: '1px solid #eee' }}>
                            <td style={{ padding: '8px 0', fontWeight: 'bold' }}>{log.date}</td>
                            <td>{totalCal} kcal</td>
                            <td>{log.steps.toLocaleString()}</td>
                            <td>{log.water} ml</td>
                            <td>{workoutsDesc || '-'}</td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                )}
              </div>

            </div>

          </div>
        </div>
      )}

      {/* CSS Rules specifically for Print layout */}
      <style dangerouslySetInnerHTML={{__html: `
        @media print {
          /* Hide everything except printable report content */
          body * {
            visibility: hidden;
          }
          .report-print-overlay,
          #printable-report,
          #printable-report * {
            visibility: visible;
          }
          /* Align report cleanly on print page */
          .report-print-overlay {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            height: auto;
            background: none !important;
            backdrop-filter: none !important;
            display: block;
            padding: 0;
          }
          .print-report-container {
            border: none !important;
            box-shadow: none !important;
            max-width: 100% !important;
            width: 100% !important;
            background: none !important;
            padding: 0 !important;
            margin: 0 !important;
          }
          .no-print {
            display: none !important;
          }
          #printable-report {
            border: none !important;
            padding: 0 !important;
          }
        }
      `}} />

    </div>
  );
}
