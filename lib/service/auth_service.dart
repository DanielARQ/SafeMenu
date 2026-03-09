import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  // Singleton para usar la misma instancia en toda la app
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();

  // Para saber quién está logueado actualmente
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // --- 1. LÓGICA DE GOOGLE SIGN-IN ---
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Iniciar el flujo de login de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; 

      // Obtener la autenticación de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear la credencial para Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firmar en Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Verificar si el usuario ya existe en Firestore
        UserModel? existingUser = await _userService.getUserProfile(firebaseUser.uid);

        if (existingUser != null) {
          _currentUser = existingUser;
          return _currentUser;
        } else {
          // Usuario nuevo
          _currentUser = UserModel(
            id: firebaseUser.uid,
            fullName: firebaseUser.displayName ?? "Usuario Nuevo",
            email: firebaseUser.email ?? "",
            allergies: [],
          );
          return _currentUser;
        }
      }
    } catch (e) {
      print("Error en Google Sign-In: $e");
    }
    return null;
  }

  // --- 2. LÓGICA DE REGISTRO CON EMAIL ---
  Future<bool> register(UserModel user, String password) async {
    try {
      // Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      if (userCredential.user != null) {
        // Creamos el modelo con el ID real de Firebase
        _currentUser = UserModel(
          id: userCredential.user!.uid,
          fullName: user.fullName,
          email: user.email,
          allergies: user.allergies,
        );
        
        // Guardar en la base de datos Firestore
        await _userService.saveUserProfile(_currentUser!);
        return true;
      }
      return false;
    } catch (e) {
      print("Error en registro: $e");
      return false;
    }
  }

  // --- 3. LÓGICA DE LOGIN CON EMAIL ---
  Future<bool> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Cargar datos desde Firestore
        _currentUser = await _userService.getUserProfile(userCredential.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      print("Error en login: $e");
      return false;
    }
  }

  // --- 4. CERRAR SESIÓN ---
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _currentUser = null;
  }
}

//codigo modificado el 26/02/2026
/*import 'package:safemenu/models/user_model.dart';
class AuthService {
  // Patrón Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Simulación de usuario logueado
  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    // Simulación de delay de red
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = User(id: "123", fullName: "Usuario Prueba", email: email);
      return true;
    }
    return false;
  }

  Future<bool> register(User user, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = user;
    return true;
  }
}*/
