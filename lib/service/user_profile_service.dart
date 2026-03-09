import 'package:safemenu/models/allergy_model.dart';

class UserProfileService {
  // Implementación Singleton
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  final List<Allergy> _userAllergies = [];

  List<Allergy> get allergies => List.unmodifiable(_userAllergies);

  void addAllergy(Allergy allergy) {
    _userAllergies.add(allergy);
  }
}