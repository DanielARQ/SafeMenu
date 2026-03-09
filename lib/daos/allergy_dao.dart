import 'package:shared_preferences/shared_preferences.dart';

class AllergyDAO {
  static final AllergyDAO _instance = AllergyDAO._internal();
  factory AllergyDAO() => _instance;
  AllergyDAO._internal();

  static const String _keySelectedAllergies = 'user_allergies';

  Future<void> saveSelectedAllergies(List<String> names) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySelectedAllergies, names);
  }

  Future<List<String>> getSelectedAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySelectedAllergies) ?? [];
  }
}