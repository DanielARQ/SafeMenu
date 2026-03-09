import 'package:safemenu/service/auth_service.dart';

class LoginController {
  final AuthService _authService = AuthService();

  // Login con correo y contraseña
  Future<bool> signIn(String email, String password) async {
    return await _authService.login(email, password);
  }

  // Login con Google
  Future<bool> signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    return user != null;
  }
}

//cambio 9 mayo 2025
/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Método para Login Tradicional
  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print("Error en login: $e");
      return false;
    }
  }

  // Método para Login con Google
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      print("Error Google Sign-In: $e");
      return false;
    }
  }
}*/