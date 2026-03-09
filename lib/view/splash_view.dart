import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safemenu/controller/splash_controller.dart';
import 'package:safemenu/service/user_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final SplashController _controller = SplashController();
  final UserService _userService = UserService();

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  void _startApp() {
    _controller.initializeApp(
      onProgressChanged: (newProgress) {
        if (mounted) {
          setState(() => _progress = newProgress);
        }
      },
      onFinished: () {
        if (mounted) {
          _checkNavigation();
        }
      },
    );
  }

  Future<void> _checkNavigation() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // 1. Si no hay sesión
    if (firebaseUser == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // 2. Si hay sesión, revisar si ya tiene perfil/alergias
    try {
      final userProfile = await _userService.getUserProfile(firebaseUser.uid);

      if (userProfile == null || userProfile.allergies.isEmpty) {
        Navigator.pushReplacementNamed(context, '/setup');
        return;
      }

      // 3. Si ya tiene alergias configuradas
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Si algo falla, por seguridad lo mandamos al login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.security, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 24),
            const Text(
              'SafeMenu',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const Text(
              'YOUR DINING SAFETY PARTNER',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4CAF50),
                    ),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'INITIALIZING...',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safemenu/controller/splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final SplashController _controller = SplashController();
  double _progress = 0.0;

  // Dentro de _SplashViewState en splash_view.dart

  // ... (tus variables _controller y _progress)

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  void _startApp() {
    _controller.initializeApp(
      onProgressChanged: (newProgress) {
        if (mounted) {
          setState(() => _progress = newProgress);
        }
      },
      onFinished: () {
        // Cuando el controlador termina la espera de 2.8 segundos, navegamos
        if (mounted) {
          _checkNavigation();
        }
      },
    );
  }

  // En tu splash_view.dart
  void _checkNavigation() async {
    final user = FirebaseAuth.instance.currentUser;

    // Saltamos el check de 'alreadyDone' para que SIEMPRE vean los consejos
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono del Escudo Verde (Basado en tu imagen)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.security, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 24),
            // Texto del Título
            const Text(
              'SafeMenu',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const Text(
              'YOUR DINING SAFETY PARTNER',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 100),
            // Barra de Progreso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4CAF50),
                    ),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'INITIALIZING...',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
