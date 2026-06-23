import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../models/user_profile.dart';


class PdfService {
  static final PdfService instance = PdfService._();
  PdfService._();

  Future<String> generateWeeklyReport(UserProfile profile) async {
    final pdf = pw.Document();
    final db = DatabaseHelper.instance;

    // Gather last 7 days
    final today = DateTime.now();
    final List<Map<String, dynamic>> weekData = [];
    for (int i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final dateStr = _dateStr(d);
      final meals = await db.getMealsForDate(dateStr);
      final workouts = await db.getWorkoutsForDate(dateStr);
      final water = await db.getWaterForDate(dateStr);
      final totalCal = meals.fold<double>(0, (s, m) => s + m.calories);
      final totalProt = meals.fold<double>(0, (s, m) => s + m.protein);
      weekData.add({
        'date': dateStr,
        'label': _dayLabel(d),
        'calories': totalCal,
        'protein': totalProt,
        'workouts': workouts.length,
        'water': water,
      });
    }

    final prs = await db.getAllPRs();
    final streak = await db.getWorkoutStreakDays();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: await PdfGoogleFonts.robotoRegular(),
          bold: await PdfGoogleFonts.robotoBold(),
        ),
        header: (ctx) => _buildHeader(ctx, profile),
        build: (ctx) => [
          _buildSummarySection(profile, weekData),
          pw.SizedBox(height: 20),
          _buildCalorieChart(weekData, profile.calorieBudget.toDouble()),
          pw.SizedBox(height: 20),
          _buildNutritionTable(weekData),
          pw.SizedBox(height: 20),
          _buildPRSection(prs),
          pw.SizedBox(height: 20),
          _buildFooter(streak),
        ],
      ),
    );

    final docDir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${docDir.path}/reports');
    if (!await reportsDir.exists()) await reportsDir.create(recursive: true);
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final file = File('${reportsDir.path}/bro_report_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  pw.Widget _buildHeader(pw.Context ctx, UserProfile profile) {
    return pw.Column(children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('BRO FITNESS REPORT',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#00E5FF'))),
        pw.Text(profile.name.toUpperCase(),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ]),
      pw.Divider(color: PdfColor.fromHex('#00E5FF'), thickness: 2),
      pw.SizedBox(height: 8),
    ]);
  }

  pw.Widget _buildSummarySection(UserProfile profile, List<Map<String, dynamic>> data) {
    final avgCal = data.fold<double>(0, (s, d) => s + (d['calories'] as double)) / data.length;
    final totalWorkouts = data.fold<int>(0, (s, d) => s + (d['workouts'] as int));
    final avgWater = data.fold<int>(0, (s, d) => s + (d['water'] as int)) ~/ data.length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1C1C28'),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('Weekly Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.Row(children: [
          _statBox('Avg Calories', '${avgCal.round()} kcal', 'Goal: ${profile.calorieBudget}'),
          pw.SizedBox(width: 16),
          _statBox('Workouts', '$totalWorkouts sessions', '${(totalWorkouts / 7 * 100).round()}% days'),
          pw.SizedBox(width: 16),
          _statBox('Avg Water', '${(avgWater / 1000).toStringAsFixed(1)}L', 'Goal: ${(profile.waterGoal / 1000).toStringAsFixed(1)}L'),
        ]),
        pw.SizedBox(height: 12),
        pw.Row(children: [
          pw.Text('Weight: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('${profile.weight} kg  |  BMI: ${profile.bmi.toStringAsFixed(1)} (${profile.bmiCategory})'),
        ]),
      ]),
    );
  }

  pw.Widget _statBox(String title, String value, String sub) {
    return pw.Expanded(child: pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#00E5FF'), width: 0.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.Text(sub, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
      ]),
    ));
  }

  pw.Widget _buildCalorieChart(List<Map<String, dynamic>> data, double budget) {
    final maxCal = data.fold<double>(budget, (m, d) => (d['calories'] as double) > m ? (d['calories'] as double) : m) * 1.1;
    const chartHeight = 100.0;
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text('Daily Calories (vs Budget)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: data.map((d) {
          final cal = d['calories'] as double;
          final barH = maxCal > 0 ? (cal / maxCal * chartHeight).clamp(2.0, chartHeight) : 2.0;
          final isOverBudget = cal > budget;
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('${cal.round()}', style: const pw.TextStyle(fontSize: 7)),
              pw.SizedBox(height: 2),
              pw.Container(
                width: 24,
                height: barH,
                decoration: pw.BoxDecoration(
                  color: isOverBudget ? PdfColor.fromHex('#FF6B6B') : PdfColor.fromHex('#00E5FF'),
                  borderRadius: pw.BorderRadius.circular(3),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(d['label'] as String, style: const pw.TextStyle(fontSize: 8)),
            ],
          );
        }).toList(),
      ),
      pw.SizedBox(height: 4),
      pw.Row(children: [
        pw.Container(width: 10, height: 10, color: PdfColor.fromHex('#00E5FF')),
        pw.SizedBox(width: 4),
        pw.Text('Under budget', style: const pw.TextStyle(fontSize: 8)),
        pw.SizedBox(width: 12),
        pw.Container(width: 10, height: 10, color: PdfColor.fromHex('#FF6B6B')),
        pw.SizedBox(width: 4),
        pw.Text('Over budget', style: const pw.TextStyle(fontSize: 8)),
      ]),
    ]);
  }

  pw.Widget _buildNutritionTable(List<Map<String, dynamic>> data) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text('Daily Breakdown', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            children: ['Date', 'Calories', 'Protein', 'Workouts', 'Water'].map((h) =>
              pw.Padding(padding: const pw.EdgeInsets.all(6),
                child: pw.Text(h, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)))).toList(),
          ),
          ...data.map((d) => pw.TableRow(children: [
            d['label'], '${(d['calories'] as double).round()} kcal',
            '${(d['protein'] as double).round()}g', '${d['workouts']}', '${(d['water'] as int)}ml',
          ].map((v) => pw.Padding(padding: const pw.EdgeInsets.all(6),
              child: pw.Text(v.toString(), style: const pw.TextStyle(fontSize: 10)))).toList())),
        ],
      ),
    ]);
  }

  pw.Widget _buildPRSection(Map<String, double> prs) {
    if (prs.isEmpty) return pw.SizedBox();
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text('Personal Records (1RM Estimates)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      ...prs.entries.take(10).map((e) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(e.key, style: const pw.TextStyle(fontSize: 11)),
          pw.Text('${e.value.toStringAsFixed(1)} kg', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#69FF47'))),
        ]),
      )),
    ]);
  }

  pw.Widget _buildFooter(int streak) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#13131A'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(children: [
        pw.Text('🔥 Current Streak: $streak days  |  '),
        pw.Text('Generated by BRO Fitness — Your data, your privacy.',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
      ]),
    );
  }

  Future<void> sharePdf(String filePath) async {
    await Share.shareXFiles([XFile(filePath)], text: 'My BRO Fitness Weekly Report');
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _dayLabel(DateTime d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];
}
