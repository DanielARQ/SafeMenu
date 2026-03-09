import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  // En user_prefs.dart
  bool get notificationsEnabled =>
      _prefs.getBool('notificationsEnabled') ?? true;
  set notificationsEnabled(bool value) =>
      _prefs.setBool('notificationsEnabled', value);

  static final UserPrefs _instance = UserPrefs._internal();
  factory UserPrefs() => _instance;
  UserPrefs._internal();

  late SharedPreferences _prefs;

  // Inicialización
  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Getters y Setters con valores por defecto para que NO salga vacío
  String get name => _prefs.getString('userName') ?? "Usuario SafeMenu";
  set name(String value) => _prefs.setString('userName', value);

  String get email => _prefs.getString('userEmail') ?? "usuario@ejemplo.com";
  set email(String value) => _prefs.setString('userEmail', value);

  List<String> get allergies => _prefs.getStringList('userAllergies') ?? [];
  set allergies(List<String> value) =>
      _prefs.setStringList('userAllergies', value);
}
