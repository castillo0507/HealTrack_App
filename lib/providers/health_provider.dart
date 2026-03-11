import 'package:flutter/foundation.dart';
import '../models/health_category.dart';
import '../models/health_entry.dart';
import '../models/health_goals.dart';
import '../services/storage_service.dart';

class HealthProvider with ChangeNotifier {
  List<HealthCategory> _categories = [];
  DailyHealthSummary? _todaySummary;
  List<HealthEntry> _recentEntries = [];
  List<DailyHealthSummary> _weeklyHistory = [];
  HealthGoals _goals = HealthGoals();
  int _streak = 0;
  bool _isLoading = true;
  DailyHealthSummary? _previousTodaySummary;
  String? _lastEntryId;

  List<HealthCategory> get categories => _categories;
  List<HealthCategory> get enabledCategories => _categories.where((c) => c.isEnabled).toList();
  DailyHealthSummary? get todaySummary => _todaySummary;
  List<HealthEntry> get recentEntries => _recentEntries;
  List<DailyHealthSummary> get weeklyHistory => _weeklyHistory;
  HealthGoals get goals => _goals;
  int get streak => _streak;
  bool get isLoading => _isLoading;
  bool get canUndoLastActivity => _previousTodaySummary != null && _lastEntryId != null;

  HealthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _categories = HealthCategory.getAllCategories();
    await loadEnabledCategories();
    await loadGoals();
    await loadTodaySummary();
    await loadWeeklyHistory();
    await loadStreak();
    await loadRecentEntries();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadEnabledCategories() async {
    final enabledIndices = await StorageService.getEnabledCategories();
    for (int i = 0; i < _categories.length; i++) {
      _categories[i] = _categories[i].copyWith(
        isEnabled: enabledIndices.contains(i),
      );
    }
    notifyListeners();
  }

  Future<void> toggleCategory(int index) async {
    _categories[index] = _categories[index].copyWith(
      isEnabled: !_categories[index].isEnabled,
    );
    await _saveEnabledCategories();
    notifyListeners();
  }

  Future<void> setCategories(List<int> enabledIndices) async {
    for (int i = 0; i < _categories.length; i++) {
      _categories[i] = _categories[i].copyWith(
        isEnabled: enabledIndices.contains(i),
      );
    }
    await _saveEnabledCategories();
    notifyListeners();
  }

  Future<void> _saveEnabledCategories() async {
    final enabledIndices = <int>[];
    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i].isEnabled) {
        enabledIndices.add(i);
      }
    }
    await StorageService.saveEnabledCategories(enabledIndices);
  }

  Future<void> loadGoals() async {
    _goals = await StorageService.getHealthGoals();
    notifyListeners();
  }

  Future<void> updateGoals(HealthGoals newGoals) async {
    _goals = newGoals;
    await StorageService.saveHealthGoals(newGoals);
    _recalculateProgress();
    notifyListeners();
  }

  Future<void> loadTodaySummary() async {
    final today = DateTime.now();
    _todaySummary = await StorageService.getSummaryForDate(today);
    
    if (_todaySummary == null) {
      // Create empty summary for today - no mock data
      _todaySummary = DailyHealthSummary(date: today);
      await StorageService.saveDailySummary(_todaySummary!);
    }
    // Ensure streak is checked at least once per day when the app is used
    await updateStreak();
    notifyListeners();
  }

  Future<void> loadWeeklyHistory() async {
    _weeklyHistory = [];
    final today = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final summary = await StorageService.getSummaryForDate(date);
      if (summary != null) {
        _weeklyHistory.add(summary);
      } else {
        _weeklyHistory.add(DailyHealthSummary(date: date));
      }
    }
    notifyListeners();
  }

  Future<void> loadRecentEntries() async {
    final entries = await StorageService.getHealthEntries();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _recentEntries = entries.take(20).toList();
    notifyListeners();
  }

  // Real-time update methods for each category
  Future<void> updateSteps(int steps, {double? caloriesBurned}) async {
    if (_todaySummary == null) return;
    _previousTodaySummary = _todaySummary;
    
    final calories = caloriesBurned ?? (steps * 0.04);
    _todaySummary = _todaySummary!.copyWith(
      steps: steps,
      caloriesBurned: calories,
    );
    
    await _saveTodaySummaryAndRecalculate();
    await _addEntry('physicalActivity', {
      'steps': steps,
      'caloriesBurned': calories,
    });
  }

  Future<void> updateWaterIntake(double liters) async {
    if (_todaySummary == null) return;
    _previousTodaySummary = _todaySummary;
    
    _todaySummary = _todaySummary!.copyWith(waterIntake: liters);
    await _saveTodaySummaryAndRecalculate();
    await _addEntry('hydration', {'waterIntake': liters});
  }

  Future<void> addWater(double mlToAdd) async {
    if (_todaySummary == null) return;
    _previousTodaySummary = _todaySummary;
    
    final newTotal = _todaySummary!.waterIntake + (mlToAdd / 1000);
    _todaySummary = _todaySummary!.copyWith(waterIntake: newTotal);
    await _saveTodaySummaryAndRecalculate();
    await _addEntry('hydration', {'waterIntake': newTotal, 'added': mlToAdd});
  }

  Future<void> updateSleep(double hours, {int? quality}) async {
    if (_todaySummary == null) return;
    _previousTodaySummary = _todaySummary;
    
    _todaySummary = _todaySummary!.copyWith(sleepHours: hours);
    await _saveTodaySummaryAndRecalculate();
    await _addEntry('sleepTracking', {'duration': hours, 'quality': quality});
  }

  Future<void> updateHeartRate(int bpm, {int? restingBpm}) async {
    if (_todaySummary == null) return;
    _previousTodaySummary = _todaySummary;
    
    _todaySummary = _todaySummary!.copyWith(
      heartRate: bpm,
      restingHeartRate: restingBpm ?? _todaySummary!.restingHeartRate,
    );
    await _saveTodaySummaryAndRecalculate();
    await _addEntry('heartHealth', {'heartRate': bpm, 'restingRate': restingBpm});
  }

  Future<void> updateVitalSigns({
    double? temperature,
    int? systolicBP,
    int? diastolicBP,
  }) async {
    if (_todaySummary == null) return;
    _previousTodaySummary = _todaySummary;
    
    _todaySummary = _todaySummary!.copyWith(
      temperature: temperature ?? _todaySummary!.temperature,
      systolicBP: systolicBP ?? _todaySummary!.systolicBP,
      diastolicBP: diastolicBP ?? _todaySummary!.diastolicBP,
    );
    await _saveTodaySummaryAndRecalculate();
    await _addEntry('vitalSigns', {
      'temperature': temperature,
      'systolic': systolicBP,
      'diastolic': diastolicBP,
    });
  }

  Future<void> updateNutrition(int calories, {int? protein, int? carbs, int? fat}) async {
    if (_todaySummary == null) return;
    _previousTodaySummary = _todaySummary;
    
    _todaySummary = _todaySummary!.copyWith(nutritionCalories: calories);
    await _saveTodaySummaryAndRecalculate();
    await _addEntry('nutrition', {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    });
  }

  Future<void> addMeal(int calories, {String? mealName}) async {
    if (_todaySummary == null) return;
    _previousTodaySummary = _todaySummary;
    
    final newTotal = _todaySummary!.nutritionCalories + calories;
    _todaySummary = _todaySummary!.copyWith(nutritionCalories: newTotal);
    await _saveTodaySummaryAndRecalculate();
    await _addEntry('nutrition', {
      'mealCalories': calories,
      'totalCalories': newTotal,
      'mealName': mealName,
    });
  }

  Future<void> updateMentalWellness({
    String? mood,
    int? stressLevel,
    int? meditationMinutes,
  }) async {
    if (_todaySummary == null) return;
    _previousTodaySummary = _todaySummary;
    
    _todaySummary = _todaySummary!.copyWith(
      mood: mood ?? _todaySummary!.mood,
      stressLevel: stressLevel ?? _todaySummary!.stressLevel,
      meditationMinutes: meditationMinutes ?? _todaySummary!.meditationMinutes,
    );
    await _saveTodaySummaryAndRecalculate();
    await _addEntry('mentalWellness', {
      'mood': mood,
      'stressLevel': stressLevel,
      'meditationMinutes': meditationMinutes,
    });
  }

  Future<void> updateWorkout({
    required int minutes,
    required String workoutType,
    int? intensity,
  }) async {
    if (_todaySummary == null) return;
    _previousTodaySummary = _todaySummary;
    
    final totalMinutes = _todaySummary!.workoutMinutes + minutes;
    _todaySummary = _todaySummary!.copyWith(
      workoutMinutes: totalMinutes,
      workoutType: workoutType,
    );
    await _saveTodaySummaryAndRecalculate();
    await _addEntry('exerciseWorkouts', {
      'duration': minutes,
      'type': workoutType,
      'intensity': intensity,
      'totalMinutes': totalMinutes,
    });
  }

  Future<void> _addEntry(String category, Map<String, dynamic> data) async {
    final entry = HealthEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryType: category,
      timestamp: DateTime.now(),
      data: data,
    );
    _lastEntryId = entry.id;
    
    await StorageService.saveHealthEntry(entry);
    _recentEntries.insert(0, entry);
    if (_recentEntries.length > 20) {
      _recentEntries = _recentEntries.sublist(0, 20);
    }
    notifyListeners();
  }

  Future<void> _saveTodaySummaryAndRecalculate() async {
    if (_todaySummary == null) return;
    
    _recalculateProgress();
    await StorageService.saveDailySummary(_todaySummary!);
    await updateStreak();
    // Ensure all views that depend on weekly history and summaries stay in sync
    await loadWeeklyHistory();
    notifyListeners();
  }

  void _recalculateProgress() {
    if (_todaySummary == null) return;
    
    int achieved = 0;
    int total = 0;
    
    for (var category in enabledCategories) {
      total++;
      switch (category.type) {
        case HealthCategoryType.physicalActivity:
          if (_todaySummary!.steps >= _goals.stepsGoal * 0.5) achieved++;
          break;
        case HealthCategoryType.heartHealth:
          if (_todaySummary!.heartRate > 0) achieved++;
          break;
        case HealthCategoryType.sleepTracking:
          if (_todaySummary!.sleepHours >= _goals.sleepGoal * 0.7) achieved++;
          break;
        case HealthCategoryType.hydration:
          if (_todaySummary!.waterIntake >= _goals.waterGoal * 0.5) achieved++;
          break;
        case HealthCategoryType.mentalWellness:
          if (_todaySummary!.mood != 'Not tracked') achieved++;
          break;
        case HealthCategoryType.nutrition:
          if (_todaySummary!.nutritionCalories > 0) achieved++;
          break;
        case HealthCategoryType.exerciseWorkouts:
          if (_todaySummary!.workoutMinutes >= _goals.workoutMinutesGoal * 0.5) achieved++;
          break;
        case HealthCategoryType.vitalSigns:
          if (_todaySummary!.temperature > 0 || _todaySummary!.systolicBP > 0) achieved++;
          break;
      }
    }
    
    final progress = total > 0 ? achieved / total : 0.0;
    _todaySummary = _todaySummary!.copyWith(progress: progress);
  }

  double getProgressForCategory(HealthCategoryType type) {
    if (_todaySummary == null) return 0;
    
    switch (type) {
      case HealthCategoryType.physicalActivity:
        return (_todaySummary!.steps / _goals.stepsGoal).clamp(0.0, 1.0);
      case HealthCategoryType.hydration:
        return (_todaySummary!.waterIntake / _goals.waterGoal).clamp(0.0, 1.0);
      case HealthCategoryType.sleepTracking:
        return (_todaySummary!.sleepHours / _goals.sleepGoal).clamp(0.0, 1.0);
      case HealthCategoryType.nutrition:
        if (_goals.caloriesGoal == 0) return 0;
        return (_todaySummary!.nutritionCalories / _goals.caloriesGoal).clamp(0.0, 1.0);
      case HealthCategoryType.exerciseWorkouts:
        return (_todaySummary!.workoutMinutes / _goals.workoutMinutesGoal).clamp(0.0, 1.0);
      case HealthCategoryType.heartHealth:
        if (_todaySummary!.heartRate == 0) return 0;
        final inRange = _todaySummary!.heartRate >= _goals.heartRateMin &&
                        _todaySummary!.heartRate <= _goals.heartRateMax;
        return inRange ? 1.0 : 0.7;
      case HealthCategoryType.vitalSigns:
        if (_todaySummary!.temperature == 0) return 0;
        final tempInRange = _todaySummary!.temperature >= _goals.temperatureMin &&
                           _todaySummary!.temperature <= _goals.temperatureMax;
        return tempInRange ? 1.0 : 0.7;
      case HealthCategoryType.mentalWellness:
        if (_todaySummary!.mood == 'Not tracked') return 0;
        if (_todaySummary!.mood == 'Great' || _todaySummary!.mood == 'Good') return 1.0;
        if (_todaySummary!.mood == 'Okay') return 0.7;
        return 0.5;
    }
  }

  double calculateOverallProgress() {
    if (enabledCategories.isEmpty) return 0;
    
    double total = 0;
    for (var category in enabledCategories) {
      total += getProgressForCategory(category.type);
    }
    return total / enabledCategories.length;
  }

  Future<void> loadStreak() async {
    final streakData = await StorageService.getStreakData();
    _streak = streakData['streak'] ?? 0;
    notifyListeners();
  }

  Future<void> updateStreak() async {
    final now = DateTime.now();
    final streakData = await StorageService.getStreakData();
    final lastActiveDate = DateTime.parse(streakData['lastActiveDate']);
    
    final lastDay = DateTime(lastActiveDate.year, lastActiveDate.month, lastActiveDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final daysDifference = today.difference(lastDay).inDays;
    
    if (daysDifference == 0) {
      return;
    } else if (daysDifference == 1) {
      _streak++;
    } else if (daysDifference > 1) {
      _streak = 1;
    }
    
    await StorageService.saveStreakData(_streak, now);
    notifyListeners();
  }

  Future<void> quickAddSteps(int stepsToAdd) async {
    if (_todaySummary == null) return;
    final newTotal = _todaySummary!.steps + stepsToAdd;
    await updateSteps(newTotal);
  }

  Future<void> quickAddWater(int mlToAdd) async {
    await addWater(mlToAdd.toDouble());
  }

  Future<void> addHealthEntry(HealthEntry entry) async {
    _lastEntryId = entry.id;
    await StorageService.saveHealthEntry(entry);
    _recentEntries.insert(0, entry);
    if (_recentEntries.length > 20) {
      _recentEntries = _recentEntries.sublist(0, 20);
    }
    notifyListeners();
  }

  Future<bool> undoLastActivity() async {
    if (_todaySummary == null || _previousTodaySummary == null) {
      return false;
    }

    _todaySummary = _previousTodaySummary;
    _previousTodaySummary = null;

    if (_lastEntryId != null) {
      await StorageService.removeHealthEntryById(_lastEntryId!);
      _lastEntryId = null;
      await loadRecentEntries();
    }

    await _saveTodaySummaryAndRecalculate();
    await loadWeeklyHistory();
    return true;
  }
}
