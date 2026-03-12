import 'package:flutter/material.dart';
import '../controller/register_controller.dart';
import '../controller/login_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final RegisterController _controller = RegisterController();
  final LoginController _loginController = LoginController();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  // Estilo visual consistente
  static const Color green = Color(0xFF4CAF50);
  static const Color dark = Color(0xFF0B1533);
  static const Color subtitle = Color(0xFF5E6F8D);
  static const Color fieldBorder = Color(0xFFD9E1EC);
  static const Color fieldIcon = Color(0xFF9AA8BF);
  static const Color bg = Color(0xFFF7F8F6);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Lógica para el registro manual
  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirm = _confirmController.text;

      final message = await _controller.handleRegister(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirm,
      );

      if (!mounted) return;

      if (message == null) {
        Navigator.pushReplacementNamed(context, '/startup');
      } else {
        _showError(message);
      }
    } catch (e) {
      if (!mounted) return;
      _showError("Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Registro/Login rápido con Google
  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);

    try {
      final ok = await _loginController.signInWithGoogle();

      if (!mounted) return;

      if (ok) {
        Navigator.pushReplacementNamed(context, '/startup');
      } else {
        _showError("No se pudo registrar con Google.");
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Barra superior con botón de atrás
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: dark),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Crear Cuenta",
                        style: TextStyle(
                          color: dark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 48,
                  ), // Espaciador para centrar el título
                ],
              ),
              const SizedBox(height: 24),
              // Logo de la App
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3EA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.restaurant, size: 42, color: green),
              ),
              const SizedBox(height: 26),
              const Text(
                "Come con tranquilidad",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dark,
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Únete a SafeMenu para escanear menús y detectar\nalérgenos en tiempo real.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subtitle,
                  fontSize: 16,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              _buildLabel("Nombre Completo"),
              const SizedBox(height: 10),
              _buildField(
                controller: _nameController,
                hint: "Ej. Juan Pérez",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 20),

              _buildLabel("Correo Electrónico"),
              const SizedBox(height: 10),
              _buildField(
                controller: _emailController,
                hint: "correo@ejemplo.com",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              _buildLabel("Contraseña"),
              const SizedBox(height: 10),
              _buildPasswordField(
                controller: _passwordController,
                hint: "Mínimo 8 caracteres",
                obscure: _obscurePassword,
                onToggle: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),

              const SizedBox(height: 20),

              _buildLabel("Confirmar Contraseña"),
              const SizedBox(height: 10),
              _buildPasswordField(
                controller: _confirmController,
                hint: "Repite tu contraseña",
                obscure: _obscureConfirm,
                onToggle: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
              ),

              const SizedBox(height: 18),

              // Aceptación de términos
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    activeColor: green,
                    onChanged: (val) {
                      setState(() => _acceptTerms = val ?? false);
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 11),
                      child: Text.rich(
                        TextSpan(
                          text: "Al registrarte, aceptas nuestros ",
                          style: const TextStyle(
                            color: subtitle,
                            fontSize: 15,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: "Términos de Servicio",
                              style: const TextStyle(
                                color: green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: " y "),
                            TextSpan(
                              text: "Política de Privacidad",
                              style: const TextStyle(
                                color: green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: "."),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Botón de Registro
              SizedBox(
                width: double.infinity,
                height: 60,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: green),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: green.withOpacity(0.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _acceptTerms ? _handleSignUp : null,
                        child: const Text(
                          "Registrarse",
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
                      "O regístrate con",
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

              const SizedBox(height: 24),

              // Botón Google
              SizedBox(
                width: double.infinity,
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
                  onPressed: _handleGoogleSignUp,
                  icon: const Icon(
                    Icons.g_mobiledata,
                    color: Colors.red,
                    size: 30,
                  ),
                  label: const Text(
                    "Google",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 34),

              // Enlace a Login
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                child: RichText(
                  text: const TextSpan(
                    text: "¿Ya tienes una cuenta? ",
                    style: TextStyle(
                      color: subtitle,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: "Inicia Sesión",
                        style: TextStyle(
                          color: green,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: dark,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

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
          hintStyle: const TextStyle(color: Color(0xFF6F7C92), fontSize: 16),
          prefixIcon: Icon(icon, color: fieldIcon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 22),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: fieldBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF6F7C92), fontSize: 16),
          prefixIcon: const Icon(Icons.lock_outline, color: fieldIcon),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: fieldIcon,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 22),
        ),
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import '../controller/register_controller.dart';
import '../controller/login_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final RegisterController _controller = RegisterController();
  final LoginController _loginController = LoginController();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  static const Color green = Color(0xFF4CAF50);
  static const Color dark = Color(0xFF0B1533);
  static const Color subtitle = Color(0xFF5E6F8D);
  static const Color fieldBorder = Color(0xFFD9E1EC);
  static const Color fieldIcon = Color(0xFF9AA8BF);
  static const Color bg = Color(0xFFF7F8F6);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirm = _confirmController.text;

      final ok = await _controller.handleRegister(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirm,
      );

      if (!mounted) return;

      if (ok) {
        Navigator.pushReplacementNamed(context, '/startup');
      } else {
        _showError("No se pudo completar el registro. Revisa los datos.");
      }
    } catch (e) {
      if (!mounted) return;
      _showError("Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);

    try {
      final ok = await _loginController.signInWithGoogle();

      if (!mounted) return;

      if (ok) {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        _showError("No se pudo registrar con Google.");
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: dark),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Crear Cuenta",
                        style: TextStyle(
                          color: dark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3EA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 42,
                  color: green,
                ),
              ),

              const SizedBox(height: 26),

              const Text(
                "Come con seguridad",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dark,
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Únete a SafeMenu para escanear menús y\ndetectar alérgenos en tiempo real.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subtitle,
                  fontSize: 16,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),

              _buildLabel("Nombre Completo"),
              const SizedBox(height: 10),
              _buildField(
                controller: _nameController,
                hint: "ej. Juan Pérez",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 20),

              _buildLabel("Correo Electrónico"),
              const SizedBox(height: 10),
              _buildField(
                controller: _emailController,
                hint: "nombre@ejemplo.com",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              _buildLabel("Contraseña"),
              const SizedBox(height: 10),
              _buildPasswordField(
                controller: _passwordController,
                hint: "Mínimo 8 caracteres",
                obscure: _obscurePassword,
                onToggle: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),

              const SizedBox(height: 20),

              _buildLabel("Confirmar Contraseña"),
              const SizedBox(height: 10),
              _buildPasswordField(
                controller: _confirmController,
                hint: "Repite tu contraseña",
                obscure: _obscureConfirm,
                onToggle: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
              ),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    activeColor: green,
                    onChanged: (val) {
                      setState(() => _acceptTerms = val ?? false);
                    },
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 11),
                      child: Text.rich(
                        TextSpan(
                          text: "Al registrarte, aceptas nuestros ",
                          style: TextStyle(
                            color: subtitle,
                            fontSize: 15,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: "Términos de Servicio",
                              style: TextStyle(
                                color: green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: " y nuestra "),
                            TextSpan(
                              text: "Política de Privacidad",
                              style: TextStyle(
                                color: green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: "."),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: green.withOpacity(0.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _acceptTerms ? _handleSignUp : null,
                        child: const Text(
                          "Registrarse",
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
                      "O regístrate con",
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

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
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
                  onPressed: _handleGoogleSignUp,
                  icon: const Icon(
                    Icons.g_mobiledata,
                    color: Colors.red,
                    size: 30,
                  ),
                  label: const Text(
                    "Google",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 34),

              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                child: RichText(
                  text: const TextSpan(
                    text: "¿Ya tienes una cuenta? ",
                    style: TextStyle(
                      color: subtitle,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: "Inicia sesión",
                        style: TextStyle(
                          color: green,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: dark,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

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
          hintStyle: const TextStyle(
            color: Color(0xFF6F7C92),
            fontSize: 16,
          ),
          prefixIcon: Icon(icon, color: fieldIcon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 22),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: fieldBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF6F7C92),
            fontSize: 16,
          ),
          prefixIcon: const Icon(Icons.lock_outline, color: fieldIcon),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: fieldIcon,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 22),
        ),
      ),
    );
  }
}*/