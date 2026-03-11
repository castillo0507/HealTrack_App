import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isInitialized = false;
  String? _userEmail;
  bool _isLoading = false;
  List<String> _recentAccounts = [];
  String _firstName = '';
  String _middleName = '';
  String _surname = '';
  String _contactNo = '';
  String _age = '';
  String _address = '';

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  List<String> get recentAccounts => List.unmodifiable(_recentAccounts);
  String get firstName => _firstName;
  String get middleName => _middleName;
  String get surname => _surname;
  String get contactNo => _contactNo;
  String get age => _age;
  String get address => _address;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Check if user was previously logged in
    _isAuthenticated = await StorageService.getIsLoggedIn();
    _userEmail = await StorageService.getUserEmail();
    _recentAccounts = await StorageService.getRecentAccounts();

    if (!_isAuthenticated) {
      _userEmail = null;
      _clearProfile();
    } else if (_userEmail != null && _userEmail!.isNotEmpty) {
      await _loadProfile(_userEmail!);
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    final normalizedEmail = StorageService.normalizeEmail(email);

    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final accountExists = await StorageService.hasRegisteredAccount(normalizedEmail);
    if (!accountExists) {
      final isLegacyRecentAccount = await StorageService.isRecentAccount(normalizedEmail);
      if (isLegacyRecentAccount) {
        await StorageService.saveAccountPassword(normalizedEmail, password);
      } else {
        _isLoading = false;
        notifyListeners();
        return 'No account found for this email. Sign up first before logging in.';
      }
    }

    final isValidPassword = await StorageService.validateCredentials(
      normalizedEmail,
      password,
    );
    if (!isValidPassword) {
      _isLoading = false;
      notifyListeners();
      return 'Incorrect password. Please try again.';
    }

    // For demo purposes, accept any valid-looking credentials
    // In a real app, this would validate against a backend
    _isAuthenticated = true;
    _userEmail = normalizedEmail;
    
    await StorageService.migrateLegacyDataIfNeeded(normalizedEmail);
    await StorageService.setIsLoggedIn(true);
    await StorageService.setUserEmail(normalizedEmail);
    await _loadProfile(normalizedEmail);
    _recentAccounts = await StorageService.getRecentAccounts();

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<String?> signUp(
    String email,
    String password, {
    required String firstName,
    required String middleName,
    required String surname,
    required String contactNo,
    required String age,
    required String address,
  }) async {
    final normalizedEmail = StorageService.normalizeEmail(email);

    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final wasRegistered = await StorageService.registerAccount(
      normalizedEmail,
      password,
      firstName: firstName,
      middleName: middleName,
      surname: surname,
      contactNo: contactNo,
      age: age,
      address: address,
    );
    if (!wasRegistered) {
      _isLoading = false;
      notifyListeners();
      return 'An account with this email already exists. Log in instead.';
    }

    // For demo purposes, automatically log in after sign up
    _isAuthenticated = true;
    _userEmail = normalizedEmail;
    
    await StorageService.setIsLoggedIn(true);
    await StorageService.setUserEmail(normalizedEmail);
    await _loadProfile(normalizedEmail);
    _recentAccounts = await StorageService.getRecentAccounts();

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userEmail = null;
    _clearProfile();
    
    await StorageService.setIsLoggedIn(false);
    await StorageService.setUserEmail(null);
    _recentAccounts = await StorageService.getRecentAccounts();
    
    notifyListeners();
  }

  Future<void> deleteCurrentAccount() async {
    final email = _userEmail;
    if (email == null || email.isEmpty) {
      return;
    }

    await StorageService.deleteAccount(email);
    _isAuthenticated = false;
    _userEmail = null;
    _clearProfile();
    _recentAccounts = await StorageService.getRecentAccounts();
    notifyListeners();
  }

  Future<void> _loadProfile(String email) async {
    final profile = await StorageService.getAccountProfile(email);
    _firstName = profile['firstName'] ?? '';
    _middleName = profile['middleName'] ?? '';
    _surname = profile['surname'] ?? '';
    _contactNo = profile['contactNo'] ?? '';
    _age = profile['age'] ?? '';
    _address = profile['address'] ?? '';
  }

  void _clearProfile() {
    _firstName = '';
    _middleName = '';
    _surname = '';
    _contactNo = '';
    _age = '';
    _address = '';
  }

  Future<void> resetPassword(String email) async {
    // In a real app, this would send a password reset email
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
