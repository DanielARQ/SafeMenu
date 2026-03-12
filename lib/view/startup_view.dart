import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safemenu/service/user_service.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  final UserService _userService = UserService();

  static const Color green = Color(0xFF4CAF50);
  static const Color dark = Color(0xFF0B1533);

  @override
  void initState() {
    super.initState();
    _checkAppFlow();
  }

  Future<void> _checkAppFlow() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (firebaseUser == null) {
      Navigator.pushReplacementNamed(context, '/welcome');
      return;
    }

    try {
      final userProfile = await _userService.getUserProfile(firebaseUser.uid);

      if (!mounted) return;

      if (userProfile == null || userProfile.allergies.isEmpty) {
        Navigator.pushReplacementNamed(context, '/setup');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 72, color: green),
            SizedBox(height: 20),
            Text(
              'SafeMenu',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: dark,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: green),
          ],
        ),
      ),
    );
  }
}