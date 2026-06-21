// IndexedDB wrapper with transparent encryption/decryption using the session key.
import { encryptData, decryptData, getSessionKey } from './crypto';

const DB_NAME = 'ultra_private_fitness_db';
const DB_VERSION = 1;

class FitnessDatabase {
  constructor() {
    this.db = null;
  }

  // Opens the IndexedDB database
  async open() {
    if (this.db) return this.db;

    return new Promise((resolve, reject) => {
      const request = indexedDB.open(DB_NAME, DB_VERSION);

      request.onupgradeneeded = (event) => {
        const db = event.target.result;
        
        // Profile store (user metrics, goals, unit settings)
        if (!db.objectStoreNames.contains('profile')) {
          db.createObjectStore('profile');
        }
        
        // Logs store (keyed by date string: YYYY-MM-DD)
        if (!db.objectStoreNames.contains('logs')) {
          db.createObjectStore('logs');
        }
        
        // Photos store (progress photo records)
        if (!db.objectStoreNames.contains('photos')) {
          db.createObjectStore('photos', { keyPath: 'id' });
        }

        // Settings store (miscellaneous configurations)
        if (!db.objectStoreNames.contains('settings')) {
          db.createObjectStore('settings');
        }
      };

      request.onsuccess = (event) => {
        this.db = event.target.result;
        resolve(this.db);
      };

      request.onerror = (event) => {
        reject(new Error('IndexedDB open error: ' + event.target.error?.message));
      };
    });
  }

  // Retrieve encryption key from active session
  getEncryptionKey() {
    const key = getSessionKey();
    if (!key) throw new Error('DATABASE_LOCKED');
    return key;
  }

  // Generic write (encrypt value before writing)
  async writeEncrypted(storeName, key, value) {
    const db = await this.open();
    const cryptoKey = this.getEncryptionKey();
    const jsonString = JSON.stringify(value);
    const encrypted = await encryptData(jsonString, cryptoKey);

    return new Promise((resolve, reject) => {
      const tx = db.transaction(storeName, 'readwrite');
      const store = tx.objectStore(storeName);
      const request = store.put(encrypted, key);

      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }

  // Generic read (decrypt value after reading)
  async readEncrypted(storeName, key) {
    const db = await this.open();
    const cryptoKey = this.getEncryptionKey();

    const encrypted = await new Promise((resolve, reject) => {
      const tx = db.transaction(storeName, 'readonly');
      const store = tx.objectStore(storeName);
      const request = store.get(key);

      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });

    if (!encrypted) return null;

    const decryptedJson = await decryptData(encrypted, cryptoKey);
    return JSON.parse(decryptedJson);
  }

  // Generic delete
  async deleteRecord(storeName, key) {
    const db = await this.open();
    return new Promise((resolve, reject) => {
      const tx = db.transaction(storeName, 'readwrite');
      const store = tx.objectStore(storeName);
      const request = store.delete(key);

      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }

  // Generic getAll for a keyPath store
  async getAllEncrypted(storeName) {
    const db = await this.open();
    const cryptoKey = this.getEncryptionKey();

    const encryptedList = await new Promise((resolve, reject) => {
      const tx = db.transaction(storeName, 'readonly');
      const store = tx.objectStore(storeName);
      const request = store.getAll();

      request.onsuccess = () => resolve(request.result || []);
      request.onerror = () => reject(request.error);
    });

    const decryptedList = [];
    for (const item of encryptedList) {
      if (item.encryptedPayload) {
        try {
          const decryptedJson = await decryptData(item.encryptedPayload, cryptoKey);
          const decryptedObject = JSON.parse(decryptedJson);
          decryptedList.push({
            id: item.id,
            ...decryptedObject
          });
        } catch (e) {
          console.error(`Skipping item ${item.id} due to decryption error:`, e);
        }
      }
    }
    return decryptedList;
  }

  // Profile management
  async saveProfile(profileData) {
    return this.writeEncrypted('profile', 'user_profile', profileData);
  }

  async getProfile() {
    return this.readEncrypted('profile', 'user_profile');
  }

  // Daily log management (contains meals, exercises, active calories, water, steps)
  async saveDailyLog(dateStr, logData) {
    return this.writeEncrypted('logs', dateStr, logData);
  }

  async getDailyLog(dateStr) {
    const log = await this.readEncrypted('logs', dateStr);
    if (!log) {
      // Return empty daily log structure if not found
      return {
        meals: [],
        workouts: [],
        water: 0,
        steps: 0,
        activeCalories: 0,
        heartRate: 0
      };
    }
    return log;
  }

  // Photo management (keyed by timestamp ID, payload has photo details)
  async addPhoto(photoData) {
    const db = await this.open();
    const cryptoKey = this.getEncryptionKey();
    const id = photoData.id || Date.now().toString();
    
    // Extract metadata and image to encrypt
    const payload = {
      date: photoData.date || new Date().toISOString().split('T')[0],
      image: photoData.image, // Base64 compressed image
      angle: photoData.angle || 'front', // front, side, back
      weight: photoData.weight || null,
      bodyfat: photoData.bodyfat || null
    };

    const encryptedPayload = await encryptData(JSON.stringify(payload), cryptoKey);

    return new Promise((resolve, reject) => {
      const tx = db.transaction('photos', 'readwrite');
      const store = tx.objectStore('photos');
      const request = store.put({ id, encryptedPayload });

      request.onsuccess = () => resolve(id);
      request.onerror = () => reject(request.error);
    });
  }

  async getPhotos() {
    return this.getAllEncrypted('photos');
  }

  async deletePhoto(id) {
    return this.deleteRecord('photos', id);
  }

  // Get raw encrypted export data for Backup
  async exportBackupData() {
    const db = await this.open();
    const backup = {
      profile: null,
      logs: {},
      photos: []
    };

    // 1. Fetch raw encrypted profile
    backup.profile = await new Promise((resolve) => {
      const tx = db.transaction('profile', 'readonly');
      const store = tx.objectStore('profile');
      const request = store.get('user_profile');
      request.onsuccess = () => resolve(request.result || null);
    });

    // 2. Fetch raw encrypted logs
    const logKeys = await new Promise((resolve) => {
      const tx = db.transaction('logs', 'readonly');
      const store = tx.objectStore('logs');
      const request = store.getAllKeys();
      request.onsuccess = () => resolve(request.result || []);
    });

    for (const key of logKeys) {
      backup.logs[key] = await new Promise((resolve) => {
        const tx = db.transaction('logs', 'readonly');
        const store = tx.objectStore('logs');
        const request = store.get(key);
        request.onsuccess = () => resolve(request.result);
      });
    }

    // 3. Fetch raw encrypted photos
    backup.photos = await new Promise((resolve) => {
      const tx = db.transaction('photos', 'readonly');
      const store = tx.objectStore('photos');
      const request = store.getAll();
      request.onsuccess = () => resolve(request.result || []);
    });

    return backup;
  }

  // Import raw encrypted backup data
  async importBackupData(backup) {
    const db = await this.open();

    // 1. Restore Profile
    if (backup.profile) {
      await new Promise((resolve, reject) => {
        const tx = db.transaction('profile', 'readwrite');
        const request = tx.objectStore('profile').put(backup.profile, 'user_profile');
        request.onsuccess = () => resolve();
        request.onerror = () => reject(request.error);
      });
    }

    // 2. Restore Logs
    for (const key of Object.keys(backup.logs)) {
      if (backup.logs[key]) {
        await new Promise((resolve, reject) => {
          const tx = db.transaction('logs', 'readwrite');
          const request = tx.objectStore('logs').put(backup.logs[key], key);
          request.onsuccess = () => resolve();
          request.onerror = () => reject(request.error);
        });
      }
    }

    // 3. Restore Photos
    if (backup.photos && Array.isArray(backup.photos)) {
      for (const photo of backup.photos) {
        await new Promise((resolve, reject) => {
          const tx = db.transaction('photos', 'readwrite');
          const request = tx.objectStore('photos').put(photo);
          request.onsuccess = () => resolve();
          request.onerror = () => reject(request.error);
        });
      }
    }
  }

  // Wipes all data (e.g. for factory reset)
  async clearAll() {
    const db = await this.open();
    const stores = ['profile', 'logs', 'photos', 'settings'];
    
    const promises = stores.map(storeName => {
      return new Promise((resolve, reject) => {
        const tx = db.transaction(storeName, 'readwrite');
        const store = tx.objectStore(storeName);
        const request = store.clear();
        request.onsuccess = () => resolve();
        request.onerror = () => reject(request.error);
      });
    });

    await Promise.all(promises);
  }
}

export const db = new FitnessDatabase();
