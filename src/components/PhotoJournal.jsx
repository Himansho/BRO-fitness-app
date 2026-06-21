import React, { useState, useEffect } from 'react';
import { db } from '../utils/db';

export default function PhotoJournal({ profile, refreshTrigger, onLogUpdated }) {
  const [photos, setPhotos] = useState([]);
  const [selectedPhotoIds, setSelectedPhotoIds] = useState([]);
  const [activePhoto, setActivePhoto] = useState(null); // for detail modal
  const [compareMode, setCompareMode] = useState(false);
  const [showUploadModal, setShowUploadModal] = useState(false);

  // Upload Form State
  const [imageFile, setImageFile] = useState(null);
  const [imagePreview, setImagePreview] = useState('');
  const [angle, setAngle] = useState('front');
  const [photoDate, setPhotoDate] = useState(new Date().toISOString().split('T')[0]);
  const [photoWeight, setPhotoWeight] = useState(profile.weight);
  const [photoBodyfat, setPhotoBodyfat] = useState('');
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    loadPhotos();
  }, [refreshTrigger]);

  const loadPhotos = async () => {
    try {
      const stored = await db.getPhotos();
      // Sort chronologically
      stored.sort((a, b) => new Date(b.date) - new Date(a.date));
      setPhotos(stored);
    } catch (err) {
      console.error('Failed to load photos', err);
    }
  };

  // Canvas Client-Side Image Compression
  const compressImage = (file) => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = (event) => {
        const img = new Image();
        img.onload = () => {
          const canvas = document.createElement('canvas');
          const max_size = 800; // max resolution
          let width = img.width;
          let height = img.height;

          if (width > height) {
            if (width > max_size) {
              height *= max_size / width;
              width = max_size;
            }
          } else {
            if (height > max_size) {
              width *= max_size / height;
              height = max_size;
            }
          }

          canvas.width = width;
          canvas.height = height;
          const ctx = canvas.getContext('2d');
          ctx.drawImage(img, 0, 0, width, height);

          // Compress to JPEG at 70% quality
          const dataUrl = canvas.toDataURL('image/jpeg', 0.7);
          resolve(dataUrl);
        };
        img.onerror = reject;
        img.src = event.target.result;
      };
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
  };

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setImageFile(file);
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleUploadSubmit = async (e) => {
    e.preventDefault();
    if (!imageFile) return;

    setUploading(true);
    try {
      // 1. Compress image to Base64 JPEG
      const compressedBase64 = await compressImage(imageFile);

      // 2. Build entry
      const photoEntry = {
        id: 'photo-' + Date.now(),
        date: photoDate,
        image: compressedBase64,
        angle: angle,
        weight: parseFloat(photoWeight) || null,
        bodyfat: parseFloat(photoBodyfat) || null
      };

      // 3. Write encrypted entry to DB
      await db.addPhoto(photoEntry);
      
      // 4. Update timeline log for that day (adds a milestone reference)
      const dayLog = await db.getDailyLog(photoDate);
      // Save weight in logs if entered
      if (photoWeight) {
        dayLog.weight = parseFloat(photoWeight);
      }
      await db.saveDailyLog(photoDate, dayLog);

      // Reset & Reload
      setShowUploadModal(false);
      setImageFile(null);
      setImagePreview('');
      setPhotoWeight(profile.weight);
      setPhotoBodyfat('');
      loadPhotos();
      onLogUpdated();
    } catch (err) {
      console.error(err);
      alert('Compression/upload failed: ' + err.message);
    } finally {
      setUploading(false);
    }
  };

  const handleDeletePhoto = async (id) => {
    if (window.confirm('Are you sure you want to delete this progress photo? This action is permanent.')) {
      try {
        await db.deletePhoto(id);
        setActivePhoto(null);
        loadPhotos();
      } catch (err) {
        console.error(err);
      }
    }
  };

  // Selection toggle for compare mode
  const toggleSelectPhoto = (e, id) => {
    e.stopPropagation();
    setSelectedPhotoIds(prev => {
      if (prev.includes(id)) {
        return prev.filter(x => x !== id);
      } else {
        if (prev.length >= 2) {
          // Keep only last selected and this one
          return [prev[1], id];
        }
        return [...prev, id];
      }
    });
  };

  const handleCompareClick = () => {
    if (selectedPhotoIds.length === 2) {
      setCompareMode(true);
    }
  };

  // Compare calculations
  const getComparePhotos = () => {
    if (selectedPhotoIds.length !== 2) return [];
    
    // Sort selected so A is older than B
    const itemA = photos.find(p => p.id === selectedPhotoIds[0]);
    const itemB = photos.find(p => p.id === selectedPhotoIds[1]);
    
    if (!itemA || !itemB) return [];

    return new Date(itemA.date) < new Date(itemB.date) ? [itemA, itemB] : [itemB, itemA];
  };

  const compareItems = getComparePhotos();
  const beforePhoto = compareItems[0];
  const afterPhoto = compareItems[1];

  const weightDiff = beforePhoto && afterPhoto && beforePhoto.weight && afterPhoto.weight
    ? (afterPhoto.weight - beforePhoto.weight).toFixed(1)
    : null;

  const bfDiff = beforePhoto && afterPhoto && beforePhoto.bodyfat && afterPhoto.bodyfat
    ? (afterPhoto.bodyfat - beforePhoto.bodyfat).toFixed(1)
    : null;

  return (
    <div className="tab-content animate-fade-in" style={{ paddingBottom: '80px' }}>
      
      {/* HEADER CONTROLS */}
      <div style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center'
      }}>
        <div>
          <h2 style={{ fontSize: '20px', fontWeight: 700, textAlign: 'left' }}>Progress Photos</h2>
          <span style={{ fontSize: '13px', color: '#9ca3af' }}>Secure, local transformation journal</span>
        </div>
        
        {/* Compare / Add Action buttons */}
        <div style={{ display: 'flex', gap: '8px' }}>
          {selectedPhotoIds.length === 2 && (
            <button
              onClick={handleCompareClick}
              className="btn btn-primary animate-scale-in"
              style={{
                width: 'auto',
                padding: '8px 16px',
                fontSize: '13px',
                background: 'linear-gradient(135deg, #8b5cf6, #a78bfa)',
                color: '#fff'
              }}
            >
              Compare (2)
            </button>
          )}
          <button
            onClick={() => setShowUploadModal(true)}
            className="btn btn-primary"
            style={{ width: 'auto', padding: '8px 16px', fontSize: '13px' }}
          >
            + Upload Photo
          </button>
        </div>
      </div>

      {/* GALLERY GRID */}
      {photos.length === 0 ? (
        <div className="card" style={{ padding: '60px 20px', color: '#6b7280', textAlign: 'center' }}>
          <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" style={{ marginBottom: '16px' }}>
            <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
            <circle cx="8.5" cy="8.5" r="1.5" />
            <polyline points="21 15 16 10 5 21" />
          </svg>
          <p style={{ fontSize: '15px' }}>No progress photos uploaded yet.</p>
          <p style={{ fontSize: '12px', marginTop: '4px' }}>Log photos regularly to track your physical transformation.</p>
        </div>
      ) : (
        <div className="photo-grid">
          {photos.map(photo => {
            const isSelected = selectedPhotoIds.includes(photo.id);
            return (
              <div
                key={photo.id}
                onClick={() => setActivePhoto(photo)}
                className={`photo-card ${isSelected ? 'selected' : ''}`}
                style={{
                  border: isSelected ? '2px solid #00f2fe' : '1px solid var(--border-color)',
                  boxShadow: isSelected ? '0 0 12px rgba(0, 242, 254, 0.3)' : 'none'
                }}
              >
                <img src={photo.image} alt={photo.angle} />
                
                {/* Angle Tag */}
                <span className="photo-tag" style={{ textTransform: 'capitalize' }}>
                  {photo.angle}
                </span>

                {/* Selection checkbox overlay */}
                <div
                  onClick={(e) => toggleSelectPhoto(e, photo.id)}
                  className={`photo-checkbox ${isSelected ? 'selected' : ''}`}
                >
                  {isSelected && (
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#000" strokeWidth="3">
                      <polyline points="20 6 9 17 4 12" />
                    </svg>
                  )}
                </div>

                {/* Date overlay */}
                <div style={{
                  position: 'absolute',
                  top: '8px',
                  left: '8px',
                  background: 'rgba(0,0,0,0.6)',
                  padding: '2px 6px',
                  borderRadius: '4px',
                  fontSize: '9px',
                  fontWeight: 600
                }}>
                  {photo.date}
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* --- ADD / UPLOAD PHOTO MODAL --- */}
      {showUploadModal && (
        <div className="modal-overlay" onClick={() => setShowUploadModal(false)}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <h3 style={{ fontSize: '18px', fontWeight: 700, marginBottom: '16px' }}>Upload Progress Photo</h3>
            
            <form onSubmit={handleUploadSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              
              {/* File Input */}
              <div className="input-group">
                <label className="input-label">Choose Photo</label>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleFileChange}
                  className="input-field"
                  required
                />
              </div>

              {/* Preview image */}
              {imagePreview && (
                <div style={{
                  width: '120px',
                  height: '160px',
                  borderRadius: '12px',
                  overflow: 'hidden',
                  border: '1px solid #2b3042',
                  margin: '0 auto',
                  background: '#12141c'
                }}>
                  <img src={imagePreview} alt="Preview" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                </div>
              )}

              {/* Angle Select */}
              <div className="input-group">
                <span className="input-label">Pose / Angle</span>
                <div className="toggle-group">
                  {['front', 'side', 'back'].map(a => (
                    <button
                      key={a}
                      type="button"
                      onClick={() => setAngle(a)}
                      className={`toggle-btn ${angle === a ? 'active' : ''}`}
                      style={{ textTransform: 'capitalize', fontSize: '12px', padding: '8px' }}
                    >
                      {a}
                    </button>
                  ))}
                </div>
              </div>

              {/* Date & Metadata */}
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div className="input-group">
                  <label className="input-label">Date</label>
                  <input
                    type="date"
                    value={photoDate}
                    onChange={e => setPhotoDate(e.target.value)}
                    className="input-field"
                    required
                  />
                </div>
                <div className="input-group">
                  <label className="input-label">Weight ({profile.unitSystem === 'metric' ? 'kg' : 'lbs'})</label>
                  <input
                    type="number"
                    step="0.1"
                    value={photoWeight}
                    onChange={e => setPhotoWeight(e.target.value)}
                    className="input-field"
                  />
                </div>
              </div>

              <div className="input-group">
                <label className="input-label">Body Fat (%) [Optional]</label>
                <input
                  type="number"
                  step="0.1"
                  placeholder="e.g. 15.4"
                  value={photoBodyfat}
                  onChange={e => setPhotoBodyfat(e.target.value)}
                  className="input-field"
                />
              </div>

              <div style={{ display: 'flex', gap: '12px', marginTop: '8px' }}>
                <button type="button" onClick={() => setShowUploadModal(false)} className="btn btn-secondary" style={{ flex: 1 }} disabled={uploading}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary" style={{ flex: 2 }} disabled={uploading || !imageFile}>
                  {uploading ? 'Shrinking & Encrypting...' : 'Save Encrypted'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* --- PHOTO DETAIL MODAL --- */}
      {activePhoto && (
        <div className="modal-overlay" onClick={() => setActivePhoto(null)}>
          <div className="modal-content" onClick={e => e.stopPropagation()} style={{ maxWidth: '400px' }}>
            <div style={{
              position: 'relative',
              width: '100%',
              aspectRatio: '3 / 4',
              borderRadius: '16px',
              overflow: 'hidden',
              border: '1px solid #2b3042',
              marginBottom: '16px',
              background: '#12141c'
            }}>
              <img src={activePhoto.image} alt="Detail" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
            </div>

            {/* Info panel */}
            <div style={{ textAlign: 'left', marginBottom: '24px' }}>
              <span style={{ fontSize: '12px', color: '#00f2fe', fontWeight: 600, textTransform: 'capitalize' }}>
                {activePhoto.angle} View
              </span>
              <h3 style={{ fontSize: '18px', fontWeight: 700, margin: '2px 0 8px' }}>Logged on {activePhoto.date}</h3>
              
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', background: '#12141c', padding: '12px', borderRadius: '8px', fontSize: '14px', border: '1px solid #2b3042' }}>
                <div>Weight: <strong>{activePhoto.weight ? `${activePhoto.weight} ${profile.unitSystem === 'metric' ? 'kg' : 'lbs'}` : 'Not logged'}</strong></div>
                <div>Body Fat: <strong>{activePhoto.bodyfat ? `${activePhoto.bodyfat}%` : 'Not logged'}</strong></div>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '12px' }}>
              <button onClick={() => handleDeletePhoto(activePhoto.id)} className="btn btn-danger" style={{ flex: 1 }}>
                Delete
              </button>
              <button onClick={() => setActivePhoto(null)} className="btn btn-secondary" style={{ flex: 1 }}>
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {/* --- BEFORE / AFTER COMPARE MODAL --- */}
      {compareMode && beforePhoto && afterPhoto && (
        <div className="modal-overlay" onClick={() => setCompareMode(false)}>
          <div className="modal-content" onClick={e => e.stopPropagation()} style={{ maxWidth: '540px' }}>
            <h3 style={{ fontSize: '18px', fontWeight: 700, marginBottom: '4px' }}>Body Transformation</h3>
            <span style={{ fontSize: '12px', color: '#9ca3af', textTransform: 'capitalize', display: 'block', marginBottom: '16px' }}>
              Side-by-side comparison ({beforePhoto.angle} angle)
            </span>

            <div className="compare-container">
              {/* Before */}
              <div className="compare-image-box">
                <div style={{ position: 'relative' }}>
                  <img src={beforePhoto.image} alt="Before" className="compare-img" />
                  <span className="photo-tag" style={{ bottom: '12px', left: '12px', background: 'rgba(239, 68, 68, 0.75)' }}>BEFORE</span>
                </div>
                <div style={{ textAlign: 'left', fontSize: '13px' }}>
                  <strong style={{ color: '#fff' }}>{beforePhoto.date}</strong>
                  <div style={{ color: '#9ca3af' }}>
                    Weight: {beforePhoto.weight ? `${beforePhoto.weight} ${profile.unitSystem === 'metric' ? 'kg' : 'lbs'}` : '-'}
                  </div>
                  <div style={{ color: '#9ca3af' }}>
                    Body Fat: {beforePhoto.bodyfat ? `${beforePhoto.bodyfat}%` : '-'}
                  </div>
                </div>
              </div>

              {/* After */}
              <div className="compare-image-box">
                <div style={{ position: 'relative' }}>
                  <img src={afterPhoto.image} alt="After" className="compare-img" />
                  <span className="photo-tag" style={{ bottom: '12px', left: '12px', background: 'rgba(16, 185, 129, 0.75)' }}>AFTER</span>
                </div>
                <div style={{ textAlign: 'left', fontSize: '13px' }}>
                  <strong style={{ color: '#fff' }}>{afterPhoto.date}</strong>
                  <div style={{ color: '#9ca3af' }}>
                    Weight: {afterPhoto.weight ? `${afterPhoto.weight} ${profile.unitSystem === 'metric' ? 'kg' : 'lbs'}` : '-'}
                  </div>
                  <div style={{ color: '#9ca3af' }}>
                    Body Fat: {afterPhoto.bodyfat ? `${afterPhoto.bodyfat}%` : '-'}
                  </div>
                </div>
              </div>
            </div>

            {/* Difference breakdown panel */}
            <div style={{
              background: '#12141c',
              border: '1px solid #2b3042',
              borderRadius: '12px',
              padding: '16px',
              margin: '20px 0',
              textAlign: 'left'
            }}>
              <h4 style={{ fontSize: '14px', color: '#00f2fe', marginBottom: '8px', fontWeight: 600 }}>Transformation Summary</h4>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', fontSize: '13px' }}>
                <div>
                  Weight Change:{' '}
                  <strong style={{ color: weightDiff !== null ? (parseFloat(weightDiff) <= 0 ? '#10b981' : '#ef4444') : '#fff' }}>
                    {weightDiff !== null ? (parseFloat(weightDiff) > 0 ? `+${weightDiff}` : weightDiff) : 'N/A'}{' '}
                    {weightDiff !== null && (profile.unitSystem === 'metric' ? 'kg' : 'lbs')}
                  </strong>
                </div>
                <div>
                  Body Fat Change:{' '}
                  <strong style={{ color: bfDiff !== null ? (parseFloat(bfDiff) <= 0 ? '#10b981' : '#ef4444') : '#fff' }}>
                    {bfDiff !== null ? (parseFloat(bfDiff) > 0 ? `+${bfDiff}` : bfDiff) : 'N/A'}{' '}
                    {bfDiff !== null && '%'}
                  </strong>
                </div>
              </div>
            </div>

            <button onClick={() => setCompareMode(false)} className="btn btn-secondary">
              Close Comparison
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
