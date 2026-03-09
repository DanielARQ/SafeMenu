import 'package:shared_preferences/shared_preferences.dart';

class PreferencesDAO {
  static final PreferencesDAO _instance = PreferencesDAO._internal();
  factory PreferencesDAO() => _instance;
  PreferencesDAO._internal();

  static const String _keyOnboardingComplete = 'onboarding_complete';

  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, value);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }
}