import React, { useState, useEffect } from 'react';
import { deriveKeyFromPin, setSessionKey } from '../utils/crypto';
import { db } from '../utils/db';

export default function PinScreen({ onUnlock }) {
  const [pin, setPin] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [shake, setShake] = useState(false);

  useEffect(() => {
    // If we have 4 digits, trigger verification
    if (pin.length === 4) {
      verifyPin(pin);
    }
  }, [pin]);

  const verifyPin = async (enteredPin) => {
    setLoading(true);
    setError('');
    
    try {
      const salt = localStorage.getItem('user_db_salt');
      if (!salt) {
        setError('No configuration found. Please reload onboarding.');
        setLoading(false);
        return;
      }

      // 1. Derive candidate key from entered PIN and stored salt
      const candidateKey = await deriveKeyFromPin(enteredPin, salt);
      
      // 2. Set temporary session key so db read will use it
      setSessionKey(candidateKey);
      
      // 3. Test key by attempting to decrypt the profile data
      const profile = await db.getProfile();
      
      if (profile) {
        // Success! Key verified
        onUnlock(profile);
      } else {
        // DB opened but profile empty (should not happen if salt exists, but clean up)
        setSessionKey(null);
        setError('Profile database is empty. Please reset.');
      }
    } catch (err) {
      // Decryption failed = wrong PIN
      setSessionKey(null);
      setError('Incorrect 4-Digit PIN. Please try again.');
      setPin('');
      setShake(true);
      setTimeout(() => setShake(false), 500);
    } finally {
      setLoading(false);
    }
  };

  const handleKeyPress = (num) => {
    if (loading) return;
    if (pin.length < 4) {
      setPin(prev => prev + num);
      setError('');
    }
  };

  const handleBackspace = () => {
    if (loading) return;
    setPin(prev => prev.slice(0, -1));
    setError('');
  };

  const handleClear = () => {
    if (loading) return;
    setPin('');
    setError('');
  };

  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: '100vh',
      backgroundColor: '#0a0b0e',
      padding: '24px',
      color: '#f3f4f6',
      fontFamily: 'Outfit, sans-serif'
    }}>
      <div style={{
        textAlign: 'center',
        maxWidth: '360px',
        width: '100%',
        animation: 'fadeIn 0.5s ease'
      }}>
        {/* Shield Icon / Logo */}
        <div style={{
          width: '64px',
          height: '64px',
          borderRadius: '16px',
          background: 'linear-gradient(135deg, rgba(0, 242, 254, 0.1), rgba(79, 172, 254, 0.1))',
          border: '1px solid rgba(0, 242, 254, 0.3)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          margin: '0 auto 24px',
          boxShadow: '0 0 20px rgba(0, 242, 254, 0.1)'
        }}>
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#00f2fe" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
            <path d="M7 11V7a5 5 0 0 1 10 0v4" />
          </svg>
        </div>

        <h2 style={{ fontSize: '24px', fontWeight: 600, marginBottom: '8px' }}>Journal Decryption</h2>
        <p style={{ color: '#9ca3af', fontSize: '14px', marginBottom: '32px' }}>
          Enter your 4-digit PIN to decrypt and access your local offline journal database.
        </p>

        {/* PIN Indicators */}
        <div 
          className={shake ? 'shake-animation' : ''}
          style={{
            display: 'flex',
            justifyContent: 'center',
            gap: '16px',
            marginBottom: '16px',
            transform: shake ? 'translateX(0)' : 'none',
            transition: 'transform 0.05s ease'
          }}
        >
          {[0, 1, 2, 3].map((index) => (
            <div
              key={index}
              style={{
                width: '16px',
                height: '16px',
                borderRadius: '50%',
                border: '2px solid rgba(0, 242, 254, 0.4)',
                backgroundColor: pin.length > index ? '#00f2fe' : 'transparent',
                boxShadow: pin.length > index ? '0 0 12px #00f2fe' : 'none',
                transition: 'all 0.15s cubic-bezier(0.4, 0, 0.2, 1)'
              }}
            />
          ))}
        </div>

        {/* Error Message */}
        <div style={{ height: '24px', marginBottom: '24px' }}>
          {error && <span style={{ color: '#ef4444', fontSize: '13px', fontWeight: 500 }}>{error}</span>}
          {loading && <span style={{ color: '#00f2fe', fontSize: '13px', fontWeight: 500 }}>Decrypting data...</span>}
        </div>

        {/* Digital Keypad */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(3, 1fr)',
          gap: '16px',
          maxWidth: '280px',
          margin: '0 auto'
        }}>
          {[1, 2, 3, 4, 5, 6, 7, 8, 9].map((num) => (
            <button
              key={num}
              onClick={() => handleKeyPress(num.toString())}
              disabled={loading}
              className="pin-key"
              style={{
                outline: 'none',
                userSelect: 'none'
              }}
            >
              {num}
            </button>
          ))}
          <button
            onClick={handleClear}
            disabled={loading}
            className="pin-key"
            style={{
              fontSize: '14px',
              fontWeight: 600,
              color: '#9ca3af',
              border: 'none',
              background: 'none',
              outline: 'none'
            }}
          >
            CLEAR
          </button>
          <button
            onClick={() => handleKeyPress('0')}
            disabled={loading}
            className="pin-key"
            style={{
              outline: 'none',
              userSelect: 'none'
            }}
          >
            0
          </button>
          <button
            onClick={handleBackspace}
            disabled={loading}
            className="pin-key"
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              border: 'none',
              background: 'none',
              outline: 'none'
            }}
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M21 4H8l-7 8 7 8h13a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2z" />
              <line x1="18" y1="9" x2="12" y2="15" />
              <line x1="12" y1="9" x2="18" y2="15" />
            </svg>
          </button>
        </div>
      </div>

      <style dangerouslySetInnerHTML={{__html: `
        @keyframes fadeIn {
          from { opacity: 0; transform: scale(0.95); }
          to { opacity: 1; transform: scale(1); }
        }
        .pin-key {
          width: 64px;
          height: 64px;
          border-radius: 50%;
          background: #1a1d28;
          border: 1px solid #2b3042;
          color: #f3f4f6;
          font-size: 24px;
          font-weight: 500;
          display: flex;
          align-items: center;
          justify-content: center;
          cursor: pointer;
          transition: all 0.15s ease;
          margin: 0 auto;
        }
        .pin-key:hover {
          background: #222634;
          border-color: #9ca3af;
        }
        .pin-key:active {
          transform: scale(0.9);
          background: #2b3042;
        }
        .shake-animation {
          animation: shake 0.5s;
        }
        @keyframes shake {
          0%, 100% { transform: translateX(0); }
          10%, 30%, 50%, 70%, 90% { transform: translateX(-6px); }
          20%, 40%, 60%, 80% { transform: translateX(6px); }
        }
      `}} />
    </div>
  );
}
