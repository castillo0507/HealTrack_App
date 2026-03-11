import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/storage_service.dart';
import '../models/health_entry.dart';
import '../models/health_goals.dart';

class SettingsProvider with ChangeNotifier {
  bool _hasCompletedOnboarding = false;
  bool _isInitialized = false;
  String? _activeUserEmail;
  int _syncVersion = 0;
  
  // Data collection consent toggles
  bool _stepCounterEnabled = true;
  bool _sleepTrackingEnabled = true;
  bool _heartRateEnabled = true;
  bool _hydrationEnabled = true;
  bool _nutritionEnabled = true;
  bool _mentalWellnessEnabled = true;
  bool _workoutEnabled = true;
  bool _vitalSignsEnabled = true;

  String _languageCode = '';

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isInitialized => _isInitialized;
  bool get stepCounterEnabled => _stepCounterEnabled;
  bool get sleepTrackingEnabled => _sleepTrackingEnabled;
  bool get heartRateEnabled => _heartRateEnabled;
  bool get hydrationEnabled => _hydrationEnabled;
  bool get nutritionEnabled => _nutritionEnabled;
  bool get mentalWellnessEnabled => _mentalWellnessEnabled;
  bool get workoutEnabled => _workoutEnabled;
  bool get vitalSignsEnabled => _vitalSignsEnabled;
  String get languageCode => _languageCode;
  bool get hasSelectedLanguage => _languageCode.isNotEmpty;
  String? get activeUserEmail => _activeUserEmail;

  SettingsProvider() {
    _resetState();
    _isInitialized = true;
  }

  void _resetState() {
    _hasCompletedOnboarding = false;
    _languageCode = '';
  }

  Future<void> syncWithUser(String? email) async {
    final currentVersion = ++_syncVersion;

    if (_activeUserEmail == email && _isInitialized) {
      return;
    }

    _activeUserEmail = email;
    _isInitialized = false;
    _resetState();
    notifyListeners();

    if (email == null || email.isEmpty) {
      _isInitialized = true;
      notifyListeners();
      return;
    }

    try {
      _hasCompletedOnboarding = await StorageService.getOnboardingComplete();
      _languageCode = await StorageService.getLanguageCode();
    } catch (_) {
      _resetState();
    }

    if (currentVersion != _syncVersion) {
      return;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await StorageService.setOnboardingComplete(true);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    _hasCompletedOnboarding = false;
    await StorageService.setOnboardingComplete(false);
    notifyListeners();
  }

  void toggleStepCounter(bool value) {
    _stepCounterEnabled = value;
    notifyListeners();
  }

  void toggleSleepTracking(bool value) {
    _sleepTrackingEnabled = value;
    notifyListeners();
  }

  void toggleHeartRate(bool value) {
    _heartRateEnabled = value;
    notifyListeners();
  }

  void toggleHydration(bool value) {
    _hydrationEnabled = value;
    notifyListeners();
  }

  void toggleNutrition(bool value) {
    _nutritionEnabled = value;
    notifyListeners();
  }

  void toggleMentalWellness(bool value) {
    _mentalWellnessEnabled = value;
    notifyListeners();
  }

  void toggleWorkout(bool value) {
    _workoutEnabled = value;
    notifyListeners();
  }

  void toggleVitalSigns(bool value) {
    _vitalSignsEnabled = value;
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) async {
    _languageCode = code;
    await StorageService.setLanguageCode(code);
    notifyListeners();
  }

  Future<void> exportData() async {
    // Load raw data
    final List<DailyHealthSummary> summaries = await StorageService.getDailySummaries();
    final entries = await StorageService.getHealthEntries();
    final HealthGoals goals = await StorageService.getHealthGoals();

    // Sort summaries by date (oldest -> newest)
    summaries.sort((a, b) => a.date.compareTo(b.date));

    // Compute overall stats
    int totalSteps = 0;
    double totalSleep = 0;
    double totalWater = 0;
    int totalWorkoutMinutes = 0;
    int activeDays = 0;

    for (final day in summaries) {
      if (day.steps > 0) activeDays++;
      totalSteps += day.steps;
      totalSleep += day.sleepHours;
      totalWater += day.waterIntake;
      totalWorkoutMinutes += day.workoutMinutes;
    }

    final daysCount = summaries.isNotEmpty ? summaries.length : 1;
    final avgSteps = daysCount > 0 ? (totalSteps / daysCount).round() : 0;
    final avgSleep = daysCount > 0 ? totalSleep / daysCount : 0.0;
    final avgWater = daysCount > 0 ? totalWater / daysCount : 0.0;
    final avgWorkout = daysCount > 0 ? (totalWorkoutMinutes / daysCount).round() : 0;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'HealTrack Data Export',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Overview of your tracked health data, reports, and analysis.',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Summary Overview',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Bullet(text: 'Tracked days: ${summaries.length}'),
          pw.Bullet(text: 'Total entries: ${entries.length}'),
          pw.Bullet(text: 'Active days (with steps): $activeDays'),
          pw.SizedBox(height: 8),
          pw.Bullet(text: 'Average steps per day: $avgSteps (goal: ${goals.stepsGoal})'),
          pw.Bullet(text: 'Average sleep per day: ${avgSleep.toStringAsFixed(1)} hrs (goal: ${goals.sleepGoal} hrs)'),
          pw.Bullet(text: 'Average water per day: ${avgWater.toStringAsFixed(1)} L (goal: ${goals.waterGoal} L)'),
          pw.Bullet(text: 'Average workout per day: $avgWorkout min (goal: ${goals.workoutMinutesGoal} min)'),

          pw.SizedBox(height: 16),
          pw.Text(
            'Recent Daily Summaries',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          if (summaries.isEmpty)
            pw.Text('No daily summaries recorded yet.')
          else
            pw.Table.fromTextArray(
              headers: const [
                'Date',
                'Steps',
                'Sleep (hrs)',
                'Water (L)',
                'Workout (min)',
              ],
              data: summaries
                  .reversed
                  .take(14)
                  .map((s) => [
                        s.date.toIso8601String().split('T').first,
                        s.steps.toString(),
                        s.sleepHours.toStringAsFixed(1),
                        s.waterIntake.toStringAsFixed(1),
                        s.workoutMinutes.toString(),
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Data Notes',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'This PDF is generated from the health data stored locally on your device. '
            'For more detailed charts and insights, open the HealTrack app and view the Insights and Report sections.',
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'healtrack_data_export_${DateTime.now().toIso8601String()}.pdf',
    );
  }

  Future<void> deleteAllData() async {
    await StorageService.clearAllData();
    await syncWithUser(_activeUserEmail);
    notifyListeners();
  }
}
