import 'package:flutter/material.dart';
import '../controller/register_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _controller = RegisterController();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // Variables para controlar la visibilidad de ambas contraseñas
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  bool _isLoading = false; // Nueva variable para mostrar carga

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        leading: const BackButton(color: Colors.black)
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // Icono de cubiertos
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), 
                borderRadius: BorderRadius.circular(20)
              ),
              child: const Icon(Icons.restaurant, color: Color(0xFF4CAF50), size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              "Crear Cuenta", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))
            ),
            const SizedBox(height: 32),
            
            // Campo Nombre
            _buildNormalField("Nombre Completo", Icons.person_outline, _nameController),
            const SizedBox(height: 16),
            
            // Campo Email
            _buildNormalField("Correo Electrónico", Icons.email_outlined, _emailController),
            const SizedBox(height: 16),
            
            // CAMPO CONTRASEÑA 1 (Con ojo)
            _buildPasswordField(
              hint: "Contraseña",
              controller: _passwordController,
              isObscured: _obscurePassword,
              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 16),
            
            // CAMPO CONTRASEÑA 2 (Con ojo)
            _buildPasswordField(
              hint: "Confirmar Contraseña",
              controller: _confirmController,
              isObscured: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            
            const SizedBox(height: 16),
            
            // Checkbox de términos
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (val) => setState(() => _acceptTerms = val!),
                ),
                const Expanded(
                  child: Text(
                    "Acepto los Términos de Servicio y Política de Privacidad.", 
                    style: TextStyle(fontSize: 12)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _isLoading 
              ? const CircularProgressIndicator(color: Color(0xFF4CAF50))
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _acceptTerms ? _handleSignUp : null,
                  child: const Text("Registrarse", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
          ],
        ),
      ),
    );
  }

  // FUNCIÓN DE REGISTRO CORREGIDA
  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);
    
    try {
      // .trim() elimina espacios en blanco accidentales que causan el error "badly formatted"
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirm = _confirmController.text;

      bool ok = await _controller.handleRegister(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirm,
      );

      if (ok) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/setup');
      } else {
        if (!mounted) return;
        _showError("No se pudo completar el registro. Revisa los datos.");
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Widget para campos de texto normales (Nombre, Email)
  Widget _buildNormalField(String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: hint.contains("Correo") ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  // Widget reutilizable para las contraseñas con OJO
  Widget _buildPasswordField({
    required String hint, 
    required TextEditingController controller, 
    required bool isObscured, 
    required VoidCallback onToggle
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(
            isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import '../controller/register_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _controller = RegisterController();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // Variables para controlar la visibilidad de ambas contraseñas
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        leading: const BackButton(color: Colors.black)
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // Icono de cubiertos
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), 
                borderRadius: BorderRadius.circular(20)
              ),
              child: const Icon(Icons.restaurant, color: Color(0xFF4CAF50), size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              "Crear Cuenta", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))
            ),
            const SizedBox(height: 32),
            
            // Campo Nombre
            _buildNormalField("Nombre Completo", Icons.person_outline, _nameController),
            const SizedBox(height: 16),
            
            // Campo Email
            _buildNormalField("Correo Electrónico", Icons.email_outlined, _emailController),
            const SizedBox(height: 16),
            
            // CAMPO CONTRASEÑA 1 (Con ojo)
            _buildPasswordField(
              hint: "Contraseña",
              controller: _passwordController,
              isObscured: _obscurePassword,
              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 16),
            
            // CAMPO CONTRASEÑA 2 (Con ojo)
            _buildPasswordField(
              hint: "Confirmar Contraseña",
              controller: _confirmController,
              isObscured: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            
            const SizedBox(height: 16),
            
            // Checkbox de términos
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (val) => setState(() => _acceptTerms = val!),
                ),
                const Expanded(
                  child: Text(
                    "Acepto los Términos de Servicio y Política de Privacidad.", 
                    style: TextStyle(fontSize: 12)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _acceptTerms ? () async {
                bool ok = await _controller.handleRegister(
                  name: _nameController.text,
                  email: _emailController.text,
                  password: _passwordController.text,
                  confirmPassword: _confirmController.text,
                );
                if (ok) Navigator.pushReplacementNamed(context, '/setup');
              } : null,
              child: const Text("Registrarse", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para campos de texto normales (Nombre, Email)
  Widget _buildNormalField(String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  // Widget reutilizable para las contraseñas con OJO
  Widget _buildPasswordField({
    required String hint, 
    required TextEditingController controller, 
    required bool isObscured, 
    required VoidCallback onToggle
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(
            isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}*/