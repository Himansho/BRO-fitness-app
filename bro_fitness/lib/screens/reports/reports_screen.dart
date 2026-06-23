import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/user_profile.dart';
import '../../services/pdf_service.dart';
import '../../services/backup_service.dart';

class ReportsScreen extends StatefulWidget {
  final UserProfile profile;
  const ReportsScreen({super.key, required this.profile});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _generatingPdf = false;
  bool _backingUp = false;
  bool _restoring = false;
  String? _lastMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(title: const Text('Reports & Backup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('📄 PDF Reports'),
          const SizedBox(height: 8),
          _reportCard(
            title: 'Weekly Progress Report',
            subtitle: 'Past 7 days — calories, protein, workouts, PRs, weight',
            icon: Icons.picture_as_pdf,
            color: AppTheme.dangerColor,
            onTap: _generateWeeklyReport,
            loading: _generatingPdf,
          ),
          const SizedBox(height: 12),
          _sectionHeader('💾 Data Backup & Restore'),
          const SizedBox(height: 8),
          _infoCard(
            '🔒 100% Private',
            'Your backup is a local .zip file. Nothing is sent to any server. Share it to email/cloud manually.',
          ),
          const SizedBox(height: 8),
          _actionCard(
            title: 'Create & Share Backup',
            subtitle: 'Export all data + progress photos as a .zip file',
            icon: Icons.backup,
            color: AppTheme.primaryColor,
            onTap: _createBackup,
            loading: _backingUp,
          ),
          const SizedBox(height: 8),
          _actionCard(
            title: 'Restore from Backup',
            subtitle: 'Import a previously exported .zip backup file',
            icon: Icons.restore,
            color: AppTheme.secondaryColor,
            onTap: _restoreBackup,
            loading: _restoring,
          ),
          const SizedBox(height: 16),
          _sectionHeader('📊 Stats'),
          const SizedBox(height: 8),
          _buildStatsCards(),
          if (_lastMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentColor.withAlpha(80)),
              ),
              child: Text(_lastMessage!, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(
      color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700,
    ));
  }

  Widget _infoCard(String title, String body) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withAlpha(40)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 4),
        Text(body, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ]),
    );
  }

  Widget _reportCard({
    required String title, required String subtitle, required IconData icon,
    required Color color, required VoidCallback onTap, required bool loading,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
            child: loading
                ? const Padding(padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor))
                : Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
            Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ])),
          Icon(Icons.chevron_right, color: color),
        ]),
      ),
    );
  }

  Widget _actionCard({
    required String title, required String subtitle, required IconData icon,
    required Color color, required VoidCallback onTap, required bool loading,
  }) => _reportCard(title: title, subtitle: subtitle, icon: icon, color: color, onTap: onTap, loading: loading);

  Widget _buildStatsCards() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadStats(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        final d = snap.data!;
        return GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5, mainAxisSpacing: 8, crossAxisSpacing: 8,
          children: [
            _statCard('Total Meals', '${d['meals']}', Icons.restaurant, AppTheme.calorieColor),
            _statCard('Workouts', '${d['workouts']}', Icons.fitness_center, AppTheme.primaryColor),
            _statCard('Progress Photos', '${d['photos']}', Icons.photo_camera, AppTheme.secondaryColor),
            _statCard('Streak', '${d['streak']} days 🔥', Icons.local_fire_department, AppTheme.warningColor),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1E2E)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ]),
    );
  }

  Future<Map<String, dynamic>> _loadStats() async {
    final db = DatabaseHelper.instance;
    final meals = await db.getAllMeals();
    final workouts = await db.getAllWorkouts();
    final photos = await db.getAllPhotos();
    final streak = await db.getWorkoutStreakDays();
    return {'meals': meals.length, 'workouts': workouts.length, 'photos': photos.length, 'streak': streak};
  }

  Future<void> _generateWeeklyReport() async {
    setState(() => _generatingPdf = true);
    try {
      final path = await PdfService.instance.generateWeeklyReport(widget.profile);
      await PdfService.instance.sharePdf(path);
      setState(() { _lastMessage = '✅ PDF saved & ready to share!'; });
    } catch (e) {
      setState(() { _lastMessage = '❌ Error: ${e.toString()}'; });
    } finally {
      setState(() => _generatingPdf = false);
    }
  }

  Future<void> _createBackup() async {
    setState(() => _backingUp = true);
    try {
      await BackupService.instance.shareBackup();
      setState(() { _lastMessage = '✅ Backup created and share sheet opened!'; });
    } catch (e) {
      setState(() { _lastMessage = '❌ Backup error: ${e.toString()}'; });
    } finally {
      setState(() => _backingUp = false);
    }
  }

  Future<void> _restoreBackup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text('This will replace ALL current data with the backup. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _restoring = true);
    try {
      final result = await BackupService.instance.pickAndRestoreBackup();
      setState(() { _lastMessage = result ?? '⚠️ Restore cancelled.'; });
    } catch (e) {
      setState(() { _lastMessage = '❌ Restore error: ${e.toString()}'; });
    } finally {
      setState(() => _restoring = false);
    }
  }
}
