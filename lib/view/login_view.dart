import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginController _loginController = LoginController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Paleta de colores consistente con WelcomeView
  static const Color green = Color(0xFF4CAF50);
  static const Color dark = Color(0xFF0B1533);
  static const Color subtitle = Color(0xFF6C7A96);
  static const Color fieldBorder = Color(0xFFD9E1EC);
  static const Color fieldIcon = Color(0xFF9AA8BF);
  static const Color bg = Color(0xFFF7F8F6);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Manejo del inicio de sesión con correo y contraseña
  Future<void> _handleEmailLogin() async {
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        _showError("Por favor, completa el correo y la contraseña.");
        return;
      }

      final ok = await _loginController.signIn(email, password);

      if (!mounted) return;

      if (ok) {
        // Redirige a startup para verificar estado del perfil/alérgenos
        Navigator.pushReplacementNamed(context, '/startup');
      } else {
        _showError("Correo o contraseña incorrectos.");
      }
    } catch (e) {
      _showError("Error al entrar: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Manejo de inicio de sesión con Google
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final ok = await _loginController.signInWithGoogle();

      if (!mounted) return;

      if (ok) {
        Navigator.pushReplacementNamed(context, '/startup');
      } else {
        _showError("No se pudo iniciar sesión con Google.");
      }
    } catch (e) {
      _showError("Error con Google: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Lógica para recuperación de contraseña
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError("Escribe tu correo primero para recuperar tu contraseña.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Te enviamos un correo para recuperar tu contraseña."),
          backgroundColor: green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = "No se pudo enviar el correo.";

      if (e.code == 'user-not-found') {
        mensaje = "No existe una cuenta con ese correo.";
      } else if (e.code == 'invalid-email') {
        mensaje = "El correo no tiene un formato válido.";
      }

      _showError(mensaje);
    } catch (e) {
      _showError("Error: ${e.toString()}");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: dark),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "SafeMenu",
                    style: TextStyle(
                      color: dark,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                "Bienvenido",
                style: TextStyle(
                  color: dark,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Inicia sesión para comer seguro.",
                style: TextStyle(
                  color: subtitle,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Correo Electrónico",
                style: TextStyle(
                  color: dark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _buildField(
                controller: _emailController,
                hint: "nombre@ejemplo.com",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Contraseña",
                    style: TextStyle(
                      color: dark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: _handleForgotPassword,
                    child: const Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(
                        color: green,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildPasswordField(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: green))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _handleEmailLogin,
                        child: const Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 30),
              Row(
                children: const [
                  Expanded(child: Divider(color: fieldBorder)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      "O continúa con",
                      style: TextStyle(
                        color: subtitle,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: fieldBorder)),
                ],
              ),
              const SizedBox(height: 25),
              Center(
                child: SizedBox(
                  width: 160,
                  height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: dark,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: fieldBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _handleGoogleLogin,
                    icon: const Icon(
                      Icons.g_mobiledata,
                      color: Colors.red,
                      size: 30,
                    ),
                    label: const Text(
                      "Google",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/register'),
                  child: RichText(
                    text: const TextSpan(
                      text: "¿No tienes una cuenta? ",
                      style: TextStyle(
                        color: subtitle,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: "Regístrate",
                          style: TextStyle(
                            color: green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Constructor de campos de texto genéricos
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: fieldBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: fieldIcon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 22),
        ),
      ),
    );
  }

  // Constructor específico para el campo de contraseña con opción de visibilidad
  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: fieldBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: "Ingresa tu contraseña",
          prefixIcon: const Icon(Icons.lock_outline, color: fieldIcon),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: fieldIcon,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 22),
        ),
      ),
    );
  }
}