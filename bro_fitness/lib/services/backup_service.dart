import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../database/database_helper.dart';

class BackupService {
  static final BackupService instance = BackupService._();
  BackupService._();

  Future<String> createBackup() async {
    final docDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${docDir.path}/backups');
    if (!await backupDir.exists()) await backupDir.create(recursive: true);

    // 1. Export all database data to JSON
    final data = await DatabaseHelper.instance.exportAllData();
    final jsonStr = jsonEncode(data);

    // 2. Create timestamped backup path
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final jsonFile = File('${backupDir.path}/bro_backup_$timestamp.json');
    await jsonFile.writeAsString(jsonStr);

    // 3. Bundle photos into zip
    final encoder = ZipFileEncoder();
    final zipPath = '${backupDir.path}/bro_backup_$timestamp.zip';
    encoder.create(zipPath);

    // Add the JSON data file
    encoder.addFile(jsonFile);

    // Add progress photos
    final photosDir = Directory('${docDir.path}/progress_photos');
    if (await photosDir.exists()) {
      final files = await photosDir.list().toList();
      for (final file in files) {
        if (file is File) {
          encoder.addFile(file, 'photos/${file.path.split('/').last}');
        }
      }
    }
    encoder.close();

    // Clean up temp JSON
    await jsonFile.delete();

    return zipPath;
  }

  Future<void> shareBackup() async {
    try {
      final zipPath = await createBackup();
      await Share.shareXFiles([XFile(zipPath)], text: 'BRO Fitness Backup');
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> pickAndRestoreBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.isEmpty) return null;

    final filePath = result.files.first.path!;
    return await _restoreFromZip(filePath);
  }

  Future<String> _restoreFromZip(String zipPath) async {
    final docDir = await getApplicationDocumentsDirectory();
    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    String? jsonContent;
    final List<ArchiveFile> photoFiles = [];

    for (final file in archive) {
      if (file.isFile) {
        if (file.name.endsWith('.json')) {
          jsonContent = utf8.decode(file.content as List<int>);
        } else if (file.name.startsWith('photos/')) {
          photoFiles.add(file);
        }
      }
    }

    if (jsonContent == null) return 'Error: No data found in backup';

    // Restore database
    final data = jsonDecode(jsonContent) as Map<String, dynamic>;
    await DatabaseHelper.instance.importAllData(data);

    // Restore photos
    final photosDir = Directory('${docDir.path}/progress_photos');
    if (!await photosDir.exists()) await photosDir.create(recursive: true);
    for (final pf in photoFiles) {
      final fileName = pf.name.split('/').last;
      final outFile = File('${photosDir.path}/$fileName');
      await outFile.writeAsBytes(pf.content as List<int>);
    }

    return 'Restore complete! Restart the app to see your data.';
  }
}
