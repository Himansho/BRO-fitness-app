import React, { useState, useEffect } from 'react';
import PinScreen from './components/PinScreen';
import Onboarding from './components/Onboarding';
import Dashboard from './components/Dashboard';
import Journal from './components/Journal';
import PhotoJournal from './components/PhotoJournal';
import Settings from './components/Settings';
import { hasSessionKey, clearSessionKey } from './utils/crypto';
import './index.css';

export default function App() {
  const [hasSalt, setHasSalt] = useState(false);
  const [isUnlocked, setIsUnlocked] = useState(false);
  const [profile, setProfile] = useState(null);
  const [activeTab, setActiveTab] = useState('dashboard');
  const [activeDate, setActiveDate] = useState(new Date().toISOString().split('T')[0]);
  
  // Triggers to reload child data when logs change
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const [activeBanner, setActiveBanner] = useState(null);

  // Check setup status on load
  useEffect(() => {
    const salt = localStorage.getItem('user_db_salt');
    if (salt) {
      setHasSalt(true);
      // If we already have a session key (e.g. hot reload during development), auto-unlock
      if (hasSessionKey()) {
        setIsUnlocked(true);
      }
    }
  }, []);

  // 1. Auto-Lock Daemon (15 minutes inactivity)
  useEffect(() => {
    if (!isUnlocked) return;

    const AUTO_LOCK_TIME = 15 * 60 * 1000; // 15 mins
    let lockTimeout;

    const resetTimer = () => {
      clearTimeout(lockTimeout);
      lockTimeout = setTimeout(() => {
        handleLockApp();
      }, AUTO_LOCK_TIME);
    };

    // User activity listeners
    const events = ['mousedown', 'keydown', 'touchstart', 'scroll'];
    events.forEach(e => window.addEventListener(e, resetTimer));
    
    resetTimer(); // Start timer

    return () => {
      clearTimeout(lockTimeout);
      events.forEach(e => window.removeEventListener(e, resetTimer));
    };
  }, [isUnlocked]);

  // 2. Smart Reminders Daemon
  useEffect(() => {
    const checkReminders = () => {
      const saved = localStorage.getItem('user_reminders');
      if (!saved) return;

      const list = JSON.parse(saved);
      const now = new Date();
      const currentHoursMin = now.toTimeString().slice(0, 5); // HH:MM

      // Find any enabled reminder matching current system time
      const matched = list.find(r => r.enabled && r.time === currentHoursMin);
      if (matched) {
        const lastTrigger = localStorage.getItem('last_trigger_' + matched.id);
        if (lastTrigger !== currentHoursMin) {
          localStorage.setItem('last_trigger_' + matched.id, currentHoursMin);
          
          // Display Top Slide-Down alert banner
          setActiveBanner(matched.text);
          setTimeout(() => setActiveBanner(null), 6000);

          // Browser System Notification
          if (Notification.permission === 'granted') {
            new Notification('Fitness Journal', {
              body: matched.text,
              icon: '/favicon.ico'
            });
          }
        }
      }
    };

    // Request notification permission on first interaction
    if (Notification.permission === 'default') {
      Notification.requestPermission();
    }

    const interval = setInterval(checkReminders, 20000); // Check every 20s
    return () => clearInterval(interval);
  }, []);

  const handleUnlock = (userProfile) => {
    setProfile(userProfile);
    setIsUnlocked(true);
  };

  const handleOnboardingComplete = (userProfile) => {
    setHasSalt(true);
    setProfile(userProfile);
    setIsUnlocked(true);
    
    // Initialize default reminders list
    const defaultReminders = [
      { id: 'r-1', time: '08:00', text: '💧 Hydration time! Drink a glass of water.', enabled: true },
      { id: 'r-2', time: '13:00', text: '🥗 Time to log your lunch details.', enabled: true },
      { id: 'r-3', time: '18:00', text: '🏃 Time for your physical activity / walk.', enabled: true },
      { id: 'r-4', time: '21:00', text: '📸 Record your weight and log end-of-day stats.', enabled: false }
    ];
    localStorage.setItem('user_reminders', JSON.stringify(defaultReminders));
  };

  const handleLockApp = () => {
    clearSessionKey();
    setIsUnlocked(false);
    setProfile(null);
  };

  const handleLogUpdated = () => {
    setRefreshTrigger(prev => prev + 1);
  };

  // State Router
  if (!hasSalt) {
    return <Onboarding onComplete={handleOnboardingComplete} />;
  }

  if (!isUnlocked) {
    return <PinScreen onUnlock={handleUnlock} />;
  }

  return (
    <div className="app-container">
      
      {/* Visual Slide-down Alert Banner */}
      {activeBanner && (
        <div style={{
          position: 'fixed',
          top: '16px',
          left: '50%',
          transform: 'translateX(-50%)',
          width: 'calc(100% - 32px)',
          maxWidth: '400px',
          background: 'linear-gradient(135deg, #1e293b, #0f172a)',
          border: '1px solid #00f2fe',
          borderRadius: '12px',
          padding: '16px',
          boxShadow: '0 10px 25px rgba(0,0,0,0.5), 0 0 15px rgba(0, 242, 254, 0.2)',
          zIndex: 9999,
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          animation: 'slideDownAlert 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) forwards'
        }}>
          <div style={{
            width: '32px',
            height: '32px',
            borderRadius: '50%',
            backgroundColor: 'rgba(0, 242, 254, 0.1)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#00f2fe',
            fontSize: '18px'
          }}>
            🔔
          </div>
          <div style={{ flex: 1, textAlign: 'left' }}>
            <strong style={{ fontSize: '13px', color: '#00f2fe', display: 'block' }}>Smart Reminder</strong>
            <span style={{ fontSize: '12px', color: '#cbd5e1' }}>{activeBanner}</span>
          </div>
          <button 
            onClick={() => setActiveBanner(null)}
            style={{ background: 'none', border: 'none', color: '#94a3b8', fontSize: '14px', cursor: 'pointer' }}
          >
            ✕
          </button>
        </div>
      )}

      {/* Main Header */}
      <header className="app-header no-print">
        <div style={{ textAlign: 'left' }}>
          <h1 style={{ fontSize: '20px', fontWeight: 800, letterSpacing: '0.05em', color: '#fff', margin: 0 }}>
            ANTIGRAVITY JOURNAL
          </h1>
          <span style={{ fontSize: '11px', color: '#00f2fe', fontWeight: 600, textTransform: 'uppercase' }}>
            100% Encrypted & Local
          </span>
        </div>
        
        {/* Private Manual Locking Lock/Unlock Icon */}
        <button
          onClick={handleLockApp}
          style={{
            background: 'none',
            border: 'none',
            color: '#9ca3af',
            cursor: 'pointer',
            padding: '6px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            borderRadius: '8px',
            border: '1px solid #2b3042'
          }}
          title="Encrypt & Lock Database"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
            <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
            <path d="M7 11V7a5 5 0 0 1 10 0v4" />
          </svg>
        </button>
      </header>

      {/* Dynamic Tab Page Display */}
      {activeTab === 'dashboard' && (
        <Dashboard 
          profile={profile} 
          activeDate={activeDate} 
          refreshTrigger={refreshTrigger}
        />
      )}
      
      {activeTab === 'journal' && (
        <Journal 
          activeDate={activeDate} 
          setActiveDate={setActiveDate} 
          onLogUpdated={handleLogUpdated}
        />
      )}
      
      {activeTab === 'photos' && (
        <PhotoJournal 
          profile={profile} 
          refreshTrigger={refreshTrigger}
          onLogUpdated={handleLogUpdated}
        />
      )}
      
      {activeTab === 'settings' && (
        <Settings 
          profile={profile} 
          onProfileUpdated={(updated) => setProfile(updated)} 
          onLogUpdated={handleLogUpdated}
        />
      )}

      {/* Bottom Navigation Menu */}
      <nav className="bottom-nav no-print">
        <button 
          onClick={() => setActiveTab('dashboard')} 
          className={`nav-item ${activeTab === 'dashboard' ? 'active' : ''}`}
        >
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <rect x="3" y="3" width="7" height="9" />
            <rect x="14" y="3" width="7" height="5" />
            <rect x="14" y="12" width="7" height="9" />
            <rect x="3" y="16" width="7" height="5" />
          </svg>
          Dashboard
        </button>
        
        <button 
          onClick={() => setActiveTab('journal')} 
          className={`nav-item ${activeTab === 'journal' ? 'active' : ''}`}
        >
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M12 20h9" />
            <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z" />
          </svg>
          Timeline
        </button>
        
        <button 
          onClick={() => setActiveTab('photos')} 
          className={`nav-item ${activeTab === 'photos' ? 'active' : ''}`}
        >
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" />
            <circle cx="12" cy="13" r="4" />
          </svg>
          Photos
        </button>
        
        <button 
          onClick={() => setActiveTab('settings')} 
          className={`nav-item ${activeTab === 'settings' ? 'active' : ''}`}
        >
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="12" cy="12" r="3" />
            <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" />
          </svg>
          Settings
        </button>
      </nav>

      {/* Style for slideDownAlert */}
      <style dangerouslySetInnerHTML={{__html: `
        @keyframes slideDownAlert {
          from { top: -80px; opacity: 0; }
          to { top: 16px; opacity: 1; }
        }
        @media print {
          .no-print {
            display: none !important;
          }
          .app-container {
            border: none !important;
            padding: 0 !important;
            background: #fff !important;
          }
        }
      `}} />

    </div>
  );
}
