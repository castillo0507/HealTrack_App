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
  static const String _activeUserEmailKey = 'user_email';
  static const String _healthGoalsKey = 'health_goals';
  static const String _languageCodeKey = 'language_code';
  static const String _recentAccountsKey = 'recent_accounts';
  static const String _migrationVersionKey = 'storage_migration_v2';
  static const String _registeredAccountsKey = 'registered_accounts';

  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  static String _scopedKey(String baseKey, String email) {
    final encodedEmail = base64Url.encode(utf8.encode(normalizeEmail(email)));
    return '${baseKey}_$encodedEmail';
  }

  static Future<String?> _getActiveUserEmail() async {
    final prefs = await _getPrefs();
    final email = prefs.getString(_activeUserEmailKey);
    if (email == null || email.isEmpty) {
      return null;
    }
    return normalizeEmail(email);
  }

  static Future<String?> _getScopedKey(String baseKey) async {
    final email = await _getActiveUserEmail();
    if (email == null) {
      return null;
    }
    return _scopedKey(baseKey, email);
  }

  static Future<bool> _hasScopedData(String email) async {
    final prefs = await _getPrefs();
    final scopedKeys = [
      _scopedKey(_healthEntriesKey, email),
      _scopedKey(_dailySummaryKey, email),
      _scopedKey(_categoriesKey, email),
      _scopedKey(_onboardingKey, email),
      _scopedKey(_streakKey, email),
      _scopedKey(_healthGoalsKey, email),
      _scopedKey(_languageCodeKey, email),
    ];

    return scopedKeys.any(prefs.containsKey);
  }

  static Future<void> migrateLegacyDataIfNeeded(String email) async {
    final prefs = await _getPrefs();
    final normalizedEmail = normalizeEmail(email);
    final migrationKey = _scopedKey(_migrationVersionKey, normalizedEmail);

    if (prefs.getBool(migrationKey) ?? false) {
      return;
    }

    final hasScopedData = await _hasScopedData(normalizedEmail);
    final legacyKeys = [
      _healthEntriesKey,
      _dailySummaryKey,
      _categoriesKey,
      _onboardingKey,
      _streakKey,
      _healthGoalsKey,
      _languageCodeKey,
    ];

    final hasLegacyData = legacyKeys.any(prefs.containsKey);

    if (hasLegacyData && !hasScopedData) {
      for (final legacyKey in legacyKeys) {
        final value = prefs.get(legacyKey);
        if (value == null) {
          continue;
        }

        final targetKey = _scopedKey(legacyKey, normalizedEmail);
        if (value is String) {
          await prefs.setString(targetKey, value);
        } else if (value is bool) {
          await prefs.setBool(targetKey, value);
        } else if (value is int) {
          await prefs.setInt(targetKey, value);
        } else if (value is double) {
          await prefs.setDouble(targetKey, value);
        } else if (value is List<String>) {
          await prefs.setStringList(targetKey, value);
        }

        await prefs.remove(legacyKey);
      }
    }

    await prefs.setBool(migrationKey, true);
  }

  // Health Entries
  static Future<void> saveHealthEntry(HealthEntry entry) async {
    final prefs = await _getPrefs();
    final key = await _getScopedKey(_healthEntriesKey);
    if (key == null) return;
    final entries = await getHealthEntries();
    entries.add(entry);
    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  static Future<List<HealthEntry>> getHealthEntries() async {
    final prefs = await _getPrefs();
    final key = await _getScopedKey(_healthEntriesKey);
    if (key == null) return [];
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => HealthEntry.fromJson(json)).toList();
  }

  static Future<void> removeHealthEntryById(String id) async {
    final prefs = await _getPrefs();
    final key = await _getScopedKey(_healthEntriesKey);
    if (key == null) return;
    final entries = await getHealthEntries();
    entries.removeWhere((e) => e.id == id);
    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
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
    final key = await _getScopedKey(_dailySummaryKey);
    if (key == null) return;
    final summaries = await getDailySummaries();
    
    // Remove existing summary for the same date
    summaries.removeWhere((s) => 
      s.date.year == summary.date.year &&
      s.date.month == summary.date.month &&
      s.date.day == summary.date.day
    );
    
    summaries.add(summary);
    final jsonList = summaries.map((s) => s.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  static Future<List<DailyHealthSummary>> getDailySummaries() async {
    final prefs = await _getPrefs();
    final key = await _getScopedKey(_dailySummaryKey);
    if (key == null) return [];
    final jsonString = prefs.getString(key);
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
    final key = await _getScopedKey(_categoriesKey);
    if (key == null) return;
    await prefs.setString(key, jsonEncode(categoryIndices));
  }

  static Future<List<int>> getEnabledCategories() async {
    final prefs = await _getPrefs();
    final key = await _getScopedKey(_categoriesKey);
    if (key == null) return [];
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.cast<int>();
  }

  // Onboarding
  static Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await _getPrefs();
    final key = await _getScopedKey(_onboardingKey);
    if (key == null) return;
    await prefs.setBool(key, complete);
  }

  static Future<bool> getOnboardingComplete() async {
    final prefs = await _getPrefs();
    final key = await _getScopedKey(_onboardingKey);
    if (key == null) return false;
    return prefs.getBool(key) ?? false;
  }

  // Streak
  static Future<void> saveStreakData(int streak, DateTime lastActiveDate) async {
    final prefs = await _getPrefs();
    final key = await _getScopedKey(_streakKey);
    if (key == null) return;
    await prefs.setString(key, jsonEncode({
      'streak': streak,
      'lastActiveDate': lastActiveDate.toIso8601String(),
    }));
  }

  static Future<Map<String, dynamic>> getStreakData() async {
    final prefs = await _getPrefs();
    final key = await _getScopedKey(_streakKey);
    if (key == null) {
      final now = DateTime.now();
      return {
        'streak': 1,
        'lastActiveDate': now.toIso8601String(),
      };
    }

    final jsonString = prefs.getString(key);
    if (jsonString == null) {
      final now = DateTime.now();
      final initial = {
        'streak': 1,
        'lastActiveDate': now.toIso8601String(),
      };
      await prefs.setString(key, jsonEncode(initial));
      return initial;
    }
    return jsonDecode(jsonString);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await _getPrefs();
    final email = await _getActiveUserEmail();
    if (email == null) return;

    final scopedKeys = [
      _scopedKey(_healthEntriesKey, email),
      _scopedKey(_dailySummaryKey, email),
      _scopedKey(_categoriesKey, email),
      _scopedKey(_onboardingKey, email),
      _scopedKey(_streakKey, email),
      _scopedKey(_healthGoalsKey, email),
      _scopedKey(_languageCodeKey, email),
    ];

    for (final key in scopedKeys) {
      await prefs.remove(key);
    }
  }

  static Future<void> deleteAccount(String email) async {
    final prefs = await _getPrefs();
    final normalizedEmail = normalizeEmail(email);

    final scopedKeys = [
      _scopedKey(_healthEntriesKey, normalizedEmail),
      _scopedKey(_dailySummaryKey, normalizedEmail),
      _scopedKey(_categoriesKey, normalizedEmail),
      _scopedKey(_onboardingKey, normalizedEmail),
      _scopedKey(_streakKey, normalizedEmail),
      _scopedKey(_healthGoalsKey, normalizedEmail),
      _scopedKey(_languageCodeKey, normalizedEmail),
      _scopedKey(_migrationVersionKey, normalizedEmail),
    ];

    for (final key in scopedKeys) {
      await prefs.remove(key);
    }

    final recentAccounts = await getRecentAccounts();
    recentAccounts.removeWhere((account) => normalizeEmail(account) == normalizedEmail);
    await prefs.setStringList(_recentAccountsKey, recentAccounts);

    final registeredAccounts = await _getRegisteredAccountsMap();
    registeredAccounts.remove(normalizedEmail);
    await _saveRegisteredAccountsMap(registeredAccounts);

    final activeEmail = await getUserEmail();
    if (activeEmail != null && normalizeEmail(activeEmail) == normalizedEmail) {
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.remove(_activeUserEmailKey);
    }
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
      final normalizedEmail = normalizeEmail(email);
      await prefs.setString(_activeUserEmailKey, normalizedEmail);
      await addRecentAccount(normalizedEmail);
    } else {
      await prefs.remove(_activeUserEmailKey);
    }
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _getPrefs();
    return prefs.getString(_activeUserEmailKey);
  }

  static Future<void> addRecentAccount(String email) async {
    final prefs = await _getPrefs();
    final normalizedEmail = normalizeEmail(email);
    final accounts = await getRecentAccounts();
    accounts.removeWhere((account) => normalizeEmail(account) == normalizedEmail);
    accounts.insert(0, normalizedEmail);
    await prefs.setStringList(
      _recentAccountsKey,
      accounts.take(8).toList(),
    );
  }

  static Future<List<String>> getRecentAccounts() async {
    final prefs = await _getPrefs();
    return prefs.getStringList(_recentAccountsKey) ?? [];
  }

  static Future<bool> isRecentAccount(String email) async {
    final normalizedEmail = normalizeEmail(email);
    final accounts = await getRecentAccounts();
    return accounts.any((account) => normalizeEmail(account) == normalizedEmail);
  }

  static Future<Map<String, dynamic>> _getRegisteredAccountsMap() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_registeredAccountsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(jsonString);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {};
  }

  static Future<void> _saveRegisteredAccountsMap(Map<String, dynamic> accounts) async {
    final prefs = await _getPrefs();
    await prefs.setString(_registeredAccountsKey, jsonEncode(accounts));
  }

  static Future<bool> hasRegisteredAccount(String email) async {
    final normalizedEmail = normalizeEmail(email);
    final accounts = await _getRegisteredAccountsMap();
    return accounts.containsKey(normalizedEmail);
  }

  static Future<bool> registerAccount(
    String email,
    String password, {
    required String firstName,
    required String middleName,
    required String surname,
    required String contactNo,
    required String age,
    required String address,
  }) async {
    final normalizedEmail = normalizeEmail(email);
    final accounts = await _getRegisteredAccountsMap();

    if (accounts.containsKey(normalizedEmail)) {
      return false;
    }

    accounts[normalizedEmail] = {
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
      'profile': {
        'firstName': firstName.trim(),
        'middleName': middleName.trim(),
        'surname': surname.trim(),
        'email': normalizedEmail,
        'contactNo': contactNo.trim(),
        'age': age.trim(),
        'address': address.trim(),
      },
    };

    await _saveRegisteredAccountsMap(accounts);
    return true;
  }

  static Future<void> saveAccountPassword(String email, String password) async {
    final normalizedEmail = normalizeEmail(email);
    final accounts = await _getRegisteredAccountsMap();
    final existingAccount = accounts[normalizedEmail];
    final existingProfile = existingAccount is Map<String, dynamic>
        ? existingAccount['profile']
        : null;

    accounts[normalizedEmail] = {
      'password': password,
      'createdAt': (existingAccount is Map<String, dynamic>)
          ? (existingAccount['createdAt'] ?? DateTime.now().toIso8601String())
          : DateTime.now().toIso8601String(),
      'profile': existingProfile is Map<String, dynamic>
          ? existingProfile
          : {
              'firstName': '',
              'middleName': '',
              'surname': '',
              'email': normalizedEmail,
              'contactNo': '',
              'age': '',
              'address': '',
            },
    };
    await _saveRegisteredAccountsMap(accounts);
  }

  static Future<Map<String, String>> getAccountProfile(String email) async {
    final normalizedEmail = normalizeEmail(email);
    final accounts = await _getRegisteredAccountsMap();
    final account = accounts[normalizedEmail];
    final profile = account is Map<String, dynamic> ? account['profile'] : null;

    if (profile is! Map<String, dynamic>) {
      return {
        'firstName': '',
        'middleName': '',
        'surname': '',
        'email': normalizedEmail,
        'contactNo': '',
        'age': '',
        'address': '',
      };
    }

    return {
      'firstName': (profile['firstName'] ?? '').toString(),
      'middleName': (profile['middleName'] ?? '').toString(),
      'surname': (profile['surname'] ?? '').toString(),
      'email': (profile['email'] ?? normalizedEmail).toString(),
      'contactNo': (profile['contactNo'] ?? '').toString(),
      'age': (profile['age'] ?? '').toString(),
      'address': (profile['address'] ?? '').toString(),
    };
  }

  static Future<bool> validateCredentials(String email, String password) async {
    final normalizedEmail = normalizeEmail(email);
    final accounts = await _getRegisteredAccountsMap();
    final account = accounts[normalizedEmail];
    if (account is! Map<String, dynamic>) {
      return false;
    }

    return account['password'] == password;
  }

  // Health Goals
  static Future<void> saveHealthGoals(HealthGoals goals) async {
    final prefs = await _getPrefs();
    final key = await _getScopedKey(_healthGoalsKey);
    if (key == null) return;
    await prefs.setString(key, jsonEncode(goals.toJson()));
  }

  static Future<HealthGoals> getHealthGoals() async {
    final prefs = await _getPrefs();
    final key = await _getScopedKey(_healthGoalsKey);
    if (key == null) return HealthGoals();
    final jsonString = prefs.getString(key);
    if (jsonString == null) {
      return HealthGoals(); // Return default goals
    }
    return HealthGoals.fromJson(jsonDecode(jsonString));
  }

  // Language
  static Future<void> setLanguageCode(String code) async {
    final prefs = await _getPrefs();
    final key = await _getScopedKey(_languageCodeKey);
    if (key == null) return;
    await prefs.setString(key, code);
  }

  static Future<String> getLanguageCode() async {
    final prefs = await _getPrefs();
    final key = await _getScopedKey(_languageCodeKey);
    if (key == null) return '';
    return prefs.getString(key) ?? '';
  }
}
