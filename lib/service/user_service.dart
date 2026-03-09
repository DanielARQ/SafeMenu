import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'user_prefs.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. OBTENER PERFIL: Se usa en AuthService para ver si el usuario ya existe
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      var doc = await _db.collection('users').doc(uid).get();
      
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print("Error al obtener perfil desde Firestore: $e");
    }
    return null;
  }

  // 2. GUARDAR PERFIL: Se usa en AllergySetupView y al registrarse
  Future<void> saveUserProfile(UserModel user) async {
    try {
      // Guardar en Firestore (Nube)
      await _db.collection('users').doc(user.id).set(
        user.toMap(), 
        SetOptions(merge: true), // Merge evita borrar datos que no enviemos
      );

      // Guardar en SharedPreferences (Local) para que la app sea rápida
      final prefs = UserPrefs();
      prefs.name = user.fullName;
      prefs.email = user.email;
      prefs.allergies = user.allergies;
      
    } catch (e) {
      print("Error al guardar perfil en Firestore: $e");
      rethrow; // Re-lanzamos el error para manejarlo en la UI si es necesario
    }
  }
}