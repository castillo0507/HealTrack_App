import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_entry.dart';
import '../models/health_goals.dart';

class StorageService {
  static const String _healthEntriesKey = 'health_entries';
  static const String _dailySummaryKey = 'daily_summary';
  static const String _categoriesKey = 'enabled_categories';
  static const String _onboardingKey = 'onboarding_complete';
  static const String _streakKey = 'streak_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _healthGoalsKey = 'health_goals';
  static const String _languageCodeKey = 'language_code';

  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Health Entries
  static Future<void> saveHealthEntry(HealthEntry entry) async {
    final prefs = await _getPrefs();
    final entries = await getHealthEntries();
    entries.add(entry);
    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_healthEntriesKey, jsonEncode(jsonList));
  }

  static Future<List<HealthEntry>> getHealthEntries() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_healthEntriesKey);
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => HealthEntry.fromJson(json)).toList();
  }

  static Future<void> removeHealthEntryById(String id) async {
    final prefs = await _getPrefs();
    final entries = await getHealthEntries();
    entries.removeWhere((e) => e.id == id);
    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_healthEntriesKey, jsonEncode(jsonList));
  }

  static Future<List<HealthEntry>> getEntriesForDate(DateTime date) async {
    final entries = await getHealthEntries();
    return entries.where((e) => 
      e.timestamp.year == date.year &&
      e.timestamp.month == date.month &&
      e.timestamp.day == date.day
    ).toList();
  }

  // Daily Summary
  static Future<void> saveDailySummary(DailyHealthSummary summary) async {
    final prefs = await _getPrefs();
    final summaries = await getDailySummaries();
    
    // Remove existing summary for the same date
    summaries.removeWhere((s) => 
      s.date.year == summary.date.year &&
      s.date.month == summary.date.month &&
      s.date.day == summary.date.day
    );
    
    summaries.add(summary);
    final jsonList = summaries.map((s) => s.toJson()).toList();
    await prefs.setString(_dailySummaryKey, jsonEncode(jsonList));
  }

  static Future<List<DailyHealthSummary>> getDailySummaries() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_dailySummaryKey);
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => DailyHealthSummary.fromJson(json)).toList();
  }

  static Future<DailyHealthSummary?> getSummaryForDate(DateTime date) async {
    final summaries = await getDailySummaries();
    try {
      return summaries.firstWhere((s) => 
        s.date.year == date.year &&
        s.date.month == date.month &&
        s.date.day == date.day
      );
    } catch (e) {
      return null;
    }
  }

  // Categories
  static Future<void> saveEnabledCategories(List<int> categoryIndices) async {
    final prefs = await _getPrefs();
    await prefs.setString(_categoriesKey, jsonEncode(categoryIndices));
  }

  static Future<List<int>> getEnabledCategories() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_categoriesKey);
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.cast<int>();
  }

  // Onboarding
  static Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_onboardingKey, complete);
  }

  static Future<bool> getOnboardingComplete() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  // Streak
  static Future<void> saveStreakData(int streak, DateTime lastActiveDate) async {
    final prefs = await _getPrefs();
    await prefs.setString(_streakKey, jsonEncode({
      'streak': streak,
      'lastActiveDate': lastActiveDate.toIso8601String(),
    }));
  }

  static Future<Map<String, dynamic>> getStreakData() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_streakKey);
    if (jsonString == null) {
      final now = DateTime.now();
      final initial = {
        'streak': 1,
        'lastActiveDate': now.toIso8601String(),
      };
      await prefs.setString(_streakKey, jsonEncode(initial));
      return initial;
    }
    return jsonDecode(jsonString);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await _getPrefs();
    await prefs.remove(_healthEntriesKey);
    await prefs.remove(_dailySummaryKey);
    await prefs.remove(_streakKey);
  }

  // Export data
  static Future<String> exportAllData() async {
    final entries = await getHealthEntries();
    final summaries = await getDailySummaries();
    final categories = await getEnabledCategories();
    
    return jsonEncode({
      'exportDate': DateTime.now().toIso8601String(),
      'healthEntries': entries.map((e) => e.toJson()).toList(),
      'dailySummaries': summaries.map((s) => s.toJson()).toList(),
      'enabledCategories': categories,
    });
  }

  // Authentication
  static Future<void> setIsLoggedIn(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<bool> getIsLoggedIn() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> setUserEmail(String? email) async {
    final prefs = await _getPrefs();
    if (email != null) {
      await prefs.setString(_userEmailKey, email);
    } else {
      await prefs.remove(_userEmailKey);
    }
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _getPrefs();
    return prefs.getString(_userEmailKey);
  }

  // Health Goals
  static Future<void> saveHealthGoals(HealthGoals goals) async {
    final prefs = await _getPrefs();
    await prefs.setString(_healthGoalsKey, jsonEncode(goals.toJson()));
  }

  static Future<HealthGoals> getHealthGoals() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_healthGoalsKey);
    if (jsonString == null) {
      return HealthGoals(); // Return default goals
    }
    return HealthGoals.fromJson(jsonDecode(jsonString));
  }

  // Language
  static Future<void> setLanguageCode(String code) async {
    final prefs = await _getPrefs();
    await prefs.setString(_languageCodeKey, code);
  }

  static Future<String> getLanguageCode() async {
    final prefs = await _getPrefs();
    return prefs.getString(_languageCodeKey) ?? '';
  }
}
