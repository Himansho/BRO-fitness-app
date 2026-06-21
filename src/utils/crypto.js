// Cryptography module utilizing Web Crypto API for client-side encryption.
// All user data is encrypted with AES-GCM using keys derived via PBKDF2 from their PIN.

let activeSessionKey = null;

// Helper: Convert ArrayBuffer to Base64 String
export function bufferToBase64(buffer) {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return window.btoa(binary);
}

// Helper: Convert Base64 String to ArrayBuffer
export function base64ToBuffer(base64) {
  const binaryString = window.atob(base64);
  const len = binaryString.length;
  const bytes = new Uint8Array(len);
  for (let i = 0; i < len; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;
}

// Helper: Generate a random Hex string for salt
export function generateSaltHex() {
  const bytes = new Uint8Array(16);
  window.crypto.getRandomValues(bytes);
  return Array.from(bytes)
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

// Helper: Convert Hex string to Uint8Array
function hexToBytes(hex) {
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < hex.length; i += 2) {
    bytes[i / 2] = parseInt(hex.substring(i, i + 2), 16);
  }
  return bytes;
}

/**
 * Derives an AES-GCM 256 key from a user PIN and a hex-encoded salt.
 */
export async function deriveKeyFromPin(pin, saltHex) {
  const encoder = new TextEncoder();
  const pinBuffer = encoder.encode(pin);
  const salt = hexToBytes(saltHex);

  const importKey = await window.crypto.subtle.importKey(
    'raw',
    pinBuffer,
    { name: 'PBKDF2' },
    false,
    ['deriveKey']
  );

  return window.crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt: salt,
      iterations: 100000,
      hash: 'SHA-256',
    },
    importKey,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt', 'decrypt']
  );
}

/**
 * Encrypts a string using AES-GCM with the derived key.
 * Returns an object containing the base64-encoded ciphertext and iv.
 */
export async function encryptData(plainText, cryptoKey) {
  const encoder = new TextEncoder();
  const encodedData = encoder.encode(plainText);
  
  // 12-byte IV for AES-GCM
  const iv = window.crypto.getRandomValues(new Uint8Array(12));
  
  const cipherBuffer = await window.crypto.subtle.encrypt(
    {
      name: 'AES-GCM',
      iv: iv,
    },
    cryptoKey,
    encodedData
  );

  return {
    ciphertext: bufferToBase64(cipherBuffer),
    iv: bufferToBase64(iv.buffer),
  };
}

/**
 * Decrypts an encrypted payload using AES-GCM with the derived key.
 * Returns the plain string.
 */
export async function decryptData(encryptedObj, cryptoKey) {
  const cipherBuffer = base64ToBuffer(encryptedObj.ciphertext);
  const ivBuffer = base64ToBuffer(encryptedObj.iv);

  try {
    const plainBuffer = await window.crypto.subtle.decrypt(
      {
        name: 'AES-GCM',
        iv: new Uint8Array(ivBuffer),
      },
      cryptoKey,
      cipherBuffer
    );

    const decoder = new TextDecoder();
    return decoder.decode(plainBuffer);
  } catch (error) {
    throw new Error('Decryption failed: Incorrect key/PIN or corrupted data.');
  }
}

// Session Key Management (in-memory only, wiped on reload/lock)
export function setSessionKey(key) {
  activeSessionKey = key;
}

export function getSessionKey() {
  return activeSessionKey;
}

export function clearSessionKey() {
  activeSessionKey = null;
}

export function hasSessionKey() {
  return activeSessionKey !== null;
}
