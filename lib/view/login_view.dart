import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.restaurant_menu,
                size: 80,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(height: 20),

              const Text(
                "¡Bienvenido de nuevo!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              _buildTextField(
                "Correo Electrónico",
                Icons.email_outlined,
                _emailController,
              ),
              const SizedBox(height: 16),

              _buildPasswordField(),
              const SizedBox(height: 24),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _handleEmailLogin,
                      child: const Text(
                        "Iniciar Sesión",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

              const SizedBox(height: 20),
              const Text("— O —", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.grey),
                ),
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: 30,
                  color: Colors.red,
                ),
                label: const Text(
                  "Continuar con Google",
                  style: TextStyle(color: Colors.black87),
                ),
                onPressed: _handleGoogleLogin,
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿No tienes cuenta? "),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      "Regístrate aquí",
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleEmailLogin() async {
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        _showError("Completa el correo y la contraseña.");
        return;
      }

      final bool ok = await _loginController.signIn(email, password);

      if (!mounted) return;

      if (ok) {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        _showError("Correo o contraseña incorrectos.");
      }
    } catch (e) {
      if (!mounted) return;
      _showError("Error al entrar: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final bool ok = await _loginController.signInWithGoogle();

      if (!mounted) return;

      if (ok) {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        _showError("No se pudo iniciar sesión con Google.");
      }
    } catch (e) {
      if (!mounted) return;
      _showError("Error con Google: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      keyboardType: hint.contains("Correo")
          ? TextInputType.emailAddress
          : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: "Contraseña",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import '../controller/login_controller.dart'; // Asegúrate de tener este controlador

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Instancia de tu controlador (ajusta según tu código)
  final _loginController = LoginController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo o Icono
              const Icon(
                Icons.restaurant_menu,
                size: 80,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(height: 20),
              const Text(
                "¡Bienvenido de nuevo!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Campo Email
              _buildTextField(
                "Correo Electrónico",
                Icons.email_outlined,
                _emailController,
              ),
              const SizedBox(height: 16),

              // Campo Password
              _buildPasswordField(),
              const SizedBox(height: 24),

              // Botón Iniciar Sesión Tradicional
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _handleEmailLogin,
                      child: const Text(
                        "Iniciar Sesión",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

              const SizedBox(height: 20),
              const Text("— O —", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              // BOTÓN DE GOOGLE (El que tenías antes, ahora integrado)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.grey),
                ),
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: 30,
                  color: Colors.red,
                ),
                label: const Text(
                  "Continuar con Google",
                  style: TextStyle(color: Colors.black87),
                ),
                onPressed: _handleGoogleLogin,
              ),

              const SizedBox(height: 30),

              // Enlace a Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿No tienes cuenta? "),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      "Regístrate aquí",
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleEmailLogin() async {
    setState(() => _isLoading = true);
    try {
      bool ok = await _loginController.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (ok && mounted) {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        _showError("Correo o contraseña incorrectos.");
      }
    } catch (e) {
      _showError("Error al entrar: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Lógica para Login con Google
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      bool ok = await _loginController.signInWithGoogle();

      if (ok && mounted) {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        _showError("No se pudo iniciar sesión con Google.");
      }
    } catch (e) {
      _showError("Error con Google: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: "Contraseña",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}*/
