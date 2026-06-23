import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/photo_entry.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  List<PhotoEntry> _photos = [];
  bool _loading = true;
  List<PhotoEntry> _compareSelected = [];
  bool _compareMode = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _loading = true);
    final photos = await DatabaseHelper.instance.getAllPhotos();
    setState(() {
      _photos = photos;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Progress Photos'),
        actions: [
          if (_photos.length >= 2)
            TextButton.icon(
              onPressed: () => setState(() {
                _compareMode = !_compareMode;
                _compareSelected.clear();
              }),
              icon: Icon(_compareMode ? Icons.close : Icons.compare, size: 18),
              label: Text(_compareMode ? 'Cancel' : 'Compare'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _photos.isEmpty
              ? _buildEmptyState()
              : Column(children: [
                  if (_compareMode) _buildCompareBar(),
                  Expanded(child: _buildPhotoGrid()),
                ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPhotoSheet,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Add Photo'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.photo_camera_outlined, color: AppTheme.textMuted, size: 72),
      const SizedBox(height: 16),
      const Text('No progress photos yet',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      const Text('Track your transformation visually!\nAdd your first photo to get started.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: _showAddPhotoSheet,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Add First Photo'),
      ),
    ]));
  }

  Widget _buildCompareBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppTheme.bgCard,
      child: Column(children: [
        Text('Select 2 photos to compare (${_compareSelected.length}/2 selected)',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        if (_compareSelected.length == 2)
          ElevatedButton(
            onPressed: () => _openCompare(_compareSelected[0], _compareSelected[1]),
            child: const Text('Compare Now'),
          ),
      ]),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.75,
      ),
      itemCount: _photos.length,
      itemBuilder: (ctx, i) => _photoCard(_photos[i]),
    );
  }

  Widget _photoCard(PhotoEntry photo) {
    final isSelected = _compareSelected.contains(photo);
    return GestureDetector(
      onTap: () {
        if (_compareMode) {
          setState(() {
            if (isSelected) {
              _compareSelected.remove(photo);
            } else if (_compareSelected.length < 2) {
              _compareSelected.add(photo);
            }
          });
        } else {
          _openFullScreen(photo);
        }
      },
      child: Stack(children: [
        Hero(
          tag: 'photo_${photo.id}',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: File(photo.filePath).existsSync()
                  ? Image.file(File(photo.filePath), fit: BoxFit.cover, width: double.infinity)
                  : Container(color: AppTheme.bgCard,
                      child: const Icon(Icons.image_not_supported, color: AppTheme.textMuted)),
            ),
          ),
        ),
        // Overlay info
        Positioned(bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withAlpha(200)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _poseBadge(photo.pose),
                const Spacer(),
                if (photo.weight != null)
                  Text('${photo.weight}kg', style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ]),
              Text(photo.date, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ]),
          ),
        ),
        if (isSelected)
          Positioned(top: 8, right: 8,
            child: Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
              child: const Icon(Icons.check, size: 16, color: Colors.black),
            ),
          ),
        // Delete button
        if (!_compareMode)
          Positioned(top: 8, left: 8,
            child: GestureDetector(
              onTap: () => _deletePhoto(photo),
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: Colors.black.withAlpha(150), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, size: 16, color: Colors.white70),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _poseBadge(String pose) {
    final colors = {
      'Front': AppTheme.primaryColor,
      'Side': AppTheme.secondaryColor,
      'Back': AppTheme.warningColor,
      'Other': AppTheme.textMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (colors[pose] ?? AppTheme.textMuted).withAlpha(200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(pose, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  void _openFullScreen(PhotoEntry photo) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _FullScreenPhoto(photo: photo)));
  }

  void _openCompare(PhotoEntry a, PhotoEntry b) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _CompareScreen(photoA: a, photoB: b)));
  }

  Future<void> _deletePhoto(PhotoEntry photo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deletePhoto(photo.id!);
      try { await File(photo.filePath).delete(); } catch (_) {}
      _loadPhotos();
    }
  }

  void _showAddPhotoSheet() {
    String pose = 'Front';
    final weightCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setBS) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Add Progress Photo', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          // Pose selection
          const Text('Pose / View', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: ['Front', 'Side', 'Back', 'Other'].map((p) => Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => setBS(() => pose = p),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: pose == p ? AppTheme.primaryColor.withAlpha(30) : AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: pose == p ? AppTheme.primaryColor : Colors.transparent),
                ),
                child: Center(child: Text(p, style: TextStyle(
                  color: pose == p ? AppTheme.primaryColor : AppTheme.textSecondary, fontSize: 12))),
              ),
            ),
          ))).toList()),
          const SizedBox(height: 16),
          TextField(controller: weightCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Weight at this date (optional)', suffixText: 'kg')),
          const SizedBox(height: 12),
          TextField(controller: notesCtrl,
              decoration: const InputDecoration(hintText: 'Notes (optional)')),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _pickImage(ctx, ImageSource.camera, pose, weightCtrl, notesCtrl),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(
              onPressed: () => _pickImage(ctx, ImageSource.gallery, pose, weightCtrl, notesCtrl),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            )),
          ]),
          const SizedBox(height: 20),
        ]),
      )),
    );
  }

  Future<void> _pickImage(BuildContext ctx, ImageSource source, String pose,
      TextEditingController weightCtrl, TextEditingController notesCtrl) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 1200);
    if (img == null) return;

    // Save to app documents
    final docDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${docDir.path}/progress_photos');
    if (!await photosDir.exists()) await photosDir.create(recursive: true);

    final filename = 'progress_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${photosDir.path}/$filename';
    await File(img.path).copy(savedPath);

    final today = DateTime.now();
    final date = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await DatabaseHelper.instance.insertPhoto(PhotoEntry(
      date: date, filePath: savedPath, pose: pose,
      weight: double.tryParse(weightCtrl.text),
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
    ));

    if (ctx.mounted) Navigator.pop(ctx);
    _loadPhotos();
  }
}

// Full-screen photo viewer
class _FullScreenPhoto extends StatelessWidget {
  final PhotoEntry photo;
  const _FullScreenPhoto({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('${photo.pose} • ${photo.date}'),
      ),
      body: Hero(
        tag: 'photo_${photo.id}',
        child: InteractiveViewer(
          child: Center(
            child: File(photo.filePath).existsSync()
                ? Image.file(File(photo.filePath))
                : const Icon(Icons.image_not_supported, color: Colors.white54, size: 80),
          ),
        ),
      ),
    );
  }
}

// Compare view
class _CompareScreen extends StatelessWidget {
  final PhotoEntry photoA;
  final PhotoEntry photoB;
  const _CompareScreen({required this.photoA, required this.photoB});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Before vs After'),
      ),
      body: Column(children: [
        // Dates bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Expanded(child: Center(child: Text(photoA.date, style: const TextStyle(color: Colors.white70, fontSize: 13)))),
            Container(width: 1, height: 20, color: Colors.white24),
            Expanded(child: Center(child: Text(photoB.date, style: const TextStyle(color: Colors.white70, fontSize: 13)))),
          ]),
        ),
        // Side by side photos
        Expanded(child: Row(children: [
          Expanded(child: _sidePhoto(photoA)),
          Container(width: 2, color: AppTheme.primaryColor),
          Expanded(child: _sidePhoto(photoB)),
        ])),
        // Metadata
        if (photoA.weight != null || photoB.weight != null)
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              if (photoA.weight != null) Text('${photoA.weight}kg',
                  style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700)),
              const Icon(Icons.arrow_forward, color: AppTheme.accentColor),
              if (photoB.weight != null) Text('${photoB.weight}kg',
                  style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.w700)),
              if (photoA.weight != null && photoB.weight != null)
                Text('${(photoB.weight! - photoA.weight!).toStringAsFixed(1)}kg change',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
      ]),
    );
  }

  Widget _sidePhoto(PhotoEntry p) {
    return Container(
      color: Colors.black,
      child: File(p.filePath).existsSync()
          ? Image.file(File(p.filePath), fit: BoxFit.contain)
          : const Icon(Icons.image_not_supported, color: Colors.white54, size: 60),
    );
  }
}
