import 'package:firebase_auth/firebase_auth.dart';
import 'package:safemenu/service/auth_service.dart';
import 'package:safemenu/models/user_model.dart';

class RegisterController {
  final AuthService _authService = AuthService();

  Future<String?> handleRegister({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.trim().isEmpty) {
      return "Escribe tu nombre completo.";
    }

    if (email.trim().isEmpty) {
      return "Escribe tu correo.";
    }

    if (password.isEmpty) {
      return "Escribe una contraseña.";
    }

    if (password.length < 6) {
      return "La contraseña debe tener al menos 6 caracteres.";
    }

    if (password != confirmPassword) {
      return "Las contraseñas no coinciden.";
    }

    final UserModel newUser = UserModel(
      id: '',
      fullName: name.trim(),
      email: email.trim(),
      allergies: const [],
    );

    try {
      final bool isRegistered = await _authService.register(newUser, password);

      if (isRegistered) {
        return null; // null = todo salió bien
      }

      return "No se pudo completar el registro.";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return "Ese correo ya está registrado. Usa otro o inicia sesión.";
        case 'invalid-email':
          return "El correo no tiene un formato válido.";
        case 'weak-password':
          return "La contraseña es demasiado débil.";
        case 'operation-not-allowed':
          return "El registro con correo y contraseña no está habilitado.";
        default:
          return "Error de registro: ${e.message ?? e.code}";
      }
    } catch (e) {
      return "Ocurrió un error inesperado.";
    }
  }
}