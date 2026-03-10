import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safemenu/view/welcome_view.dart';

import 'firebase_options.dart';

import 'package:safemenu/service/user_prefs.dart';

import 'package:safemenu/view/splash_view.dart';
import 'package:safemenu/view/onboarding_view.dart';
import 'package:safemenu/view/login_view.dart';
import 'package:safemenu/view/register_view.dart';
import 'package:safemenu/view/main_wrapper.dart';
import 'package:safemenu/view/allergy_setup_view.dart';
import 'package:safemenu/view/camera_view.dart';
import 'package:safemenu/view/scan_results_view.dart';
import 'package:safemenu/view/detail_view.dart';
import 'package:safemenu/view/history_view.dart';
import 'package:safemenu/view/settings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = UserPrefs();
  await prefs.initPrefs();

  runApp(const SafeMenuApp());
}

class SafeMenuApp extends StatelessWidget {
  const SafeMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeMenu',
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeView(),
        '/': (context) => const SplashView(),
        '/onboarding': (context) => const OnboardingView(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/home': (context) => const MainWrapper(),
        '/setup': (context) => const AllergySetupView(),
        '/camera': (context) => const CameraView(),
        '/results': (context) => const ScanResultsView(),
        '/detail': (context) => const DetailView(),
        '/profile': (context) => const SettingsView(),
        '/history': (context) => const HistoryView(),
      },
    );
  }
}

/**
 * const SafeMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeMenu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashView(),
        '/onboarding': (context) => const OnboardingView(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/setup': (context) => const AllergySetupView(),
        '/main_wrapper': (context) => const MainWrapper(), // <--- ESTA LÍNEA ES LA QUE FALTA
        '/home': (context) => const MainWrapper(),
        '/camera': (context) => const CameraView(),
        '/results': (context) => const ScanResultsView(),
        '/detail': (context) => const DetailView(),
      },
    );
  }
 */
