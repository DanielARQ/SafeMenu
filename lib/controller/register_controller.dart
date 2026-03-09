import 'package:safemenu/service/auth_service.dart';
import 'package:safemenu/models/user_model.dart';

class RegisterController {
  final AuthService _authService = AuthService();

  Future<bool> handleRegister({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Validaciones básicas
    if (name.trim().isEmpty) return false;
    if (email.trim().isEmpty) return false;
    if (password.isEmpty) return false;
    if (password != confirmPassword) return false;

    // Modelo temporal; AuthService reemplaza el id con el uid real de Firebase
    final UserModel newUser = UserModel(
      id: '',
      fullName: name.trim(),
      email: email.trim(),
      allergies: const [],
    );

    final bool isRegistered = await _authService.register(newUser, password);
    return isRegistered;
  }
}
//codigo modificado el 26/02/2026
/*import 'package:safemenu/service/auth_service.dart';
import '../models/user_model.dart';

class RegisterController {
  final AuthService _authService = AuthService();

  Future<bool> handleRegister({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // 1. Validaciones de lógica de negocio
    if (name.isEmpty || email.isEmpty || password.isEmpty) return false;
    if (password != confirmPassword) return false;

    // 2. Intentar registrar en el servicio
    User newUser = User(fullName: name, email: email);
    bool isRegistered = await _authService.register(newUser, password);
    
    return isRegistered;
  }
}*/