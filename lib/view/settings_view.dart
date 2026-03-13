import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safemenu/service/user_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final prefs = UserPrefs();
  late bool _isNotifActive;

  @override
  void initState() {
    super.initState();
    _isNotifActive = prefs.notificationsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    String userName = prefs.name.isEmpty ? "Usuario" : prefs.name;
    String userEmail =
        prefs.email.isEmpty ? "correo@ejemplo.com" : prefs.email;
    List<String> myAllergies = prefs.allergies;

    final String initial =
        userName.isNotEmpty ? userName.trim()[0].toUpperCase() : "U";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Perfil",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.green),
            onPressed: () {
              // Aquí podrías abrir un diálogo para editar el nombre
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8F5E9),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.25),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green[100]!),
                    ),
                    child: const Text(
                      "MIEMBRO PREMIUM",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildSectionHeader("MIS ALERGIAS", Icons.add, () async {
              await Navigator.pushNamed(context, '/setup');
              setState(() {});
            }),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: myAllergies.isEmpty
                  ? const Text(
                      "No has seleccionado alergias",
                      style: TextStyle(color: Colors.grey),
                    )
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: myAllergies
                          .map((allergy) => _buildAllergyChip(allergy))
                          .toList(),
                    ),
            ),

            const SizedBox(height: 25),

            _buildSectionHeader("CONFIGURACIÓN", null, null),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    Icons.notifications_none_rounded,
                    "Notificaciones",
                    _isNotifActive ? "Activado" : "Desactivado",
                    _isNotifActive ? Colors.green : Colors.grey,
                    onTap: () {
                      setState(() {
                        _isNotifActive = !_isNotifActive;
                        prefs.notificationsEnabled = _isNotifActive;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isNotifActive
                                ? "Notificaciones activadas"
                                : "Notificaciones silenciadas",
                          ),
                          duration: const Duration(milliseconds: 500),
                          backgroundColor:
                              _isNotifActive ? Colors.green : Colors.grey,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildMenuTile(
                    Icons.lock_outline_rounded,
                    "Privacidad",
                    "Gestionar datos",
                    Colors.purple,
                    onTap: () => _showDeleteDataDialog(),
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildMenuTile(
                    Icons.shield_outlined,
                    "Seguridad",
                    "Cambiar clave",
                    Colors.orange,
                    onTap: () => _showResetPasswordDialog(context),
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildMenuTile(
                    Icons.logout_rounded,
                    "Cerrar Sesión",
                    null,
                    Colors.red,
                    onTap: () async {
                      await GoogleSignIn().signOut();
                      await FirebaseAuth.instance.signOut();

                      if (!mounted) return;

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/welcome',
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData? actionIcon,
    VoidCallback? onAction,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          if (actionIcon != null)
            GestureDetector(
              onTap: onAction,
              child: const Icon(
                Icons.add_circle_outline,
                size: 22,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAllergyChip(String label) {
    return GestureDetector(
      onTap: () async {
        List<String> currentAllergies = List.from(prefs.allergies);
        currentAllergies.remove(label);
        prefs.allergies = currentAllergies;

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$label eliminado"),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC8E6C9)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.close, size: 14, color: Color(0xFF2E7D32)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    String? trailingText,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          const SizedBox(width: 5),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.black26,
          ),
        ],
      ),
    );
  }

  void _showActionDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Ajustes de $title"),
        content: Text(
          "Aquí podrás gestionar tus preferencias de $title en la próxima actualización.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar mis datos"),
        content: const Text(
          "¿Estás seguro? Se borrarán tus alergias y preferencias guardadas permanentemente.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text(
              "Eliminar Todo",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cambiar Contraseña"),
        content: Text(
          "Enviaremos un correo a ${prefs.email} para que restaures tu clave.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: prefs.email,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Correo enviado correctamente")),
              );
            },
            child: const Text(
              "Enviar correo",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}