import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safemenu/service/ai_service.dart';
import 'package:safemenu/service/user_prefs.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final UserPrefs _prefs = UserPrefs();
  final AIService _aiService = AIService();
  
  List<String> _userAllergies = [];
  List<Map<String, String>> _dynamicTips = [];
  bool _isLoadingTips = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // 1. Cargamos las alergias locales (que vienen de Firebase/Setup)
    setState(() {
      _userAllergies = _prefs.allergies;
    });

    // 2. Pedimos a la IA consejos basados en esas alergias
    await _loadDynamicTips();
  }

  Future<void> _loadDynamicTips() async {
    final tips = await _aiService.getDynamicSecurityTips(_userAllergies);
    if (mounted) {
      setState(() {
        _dynamicTips = tips;
        _isLoadingTips = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDynamicTips, // Permite al usuario refrescar los consejos
          color: const Color(0xFF4CAF50),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: SALUDO ---
                _buildHeader(),
                const SizedBox(height: 25),

                // --- TARJETA PRINCIPAL DE ESCANEO ---
                _buildMainScanCard(context),
                const SizedBox(height: 25),

                // --- SECCIÓN: RESUMEN DE MIS ALERGIAS ---
                const Text(
                  "Mis Alergias Actuales",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                _buildAllergySummaryCard(context),
                const SizedBox(height: 30),

                // --- SECCIÓN: CONSEJOS DINÁMICOS DE LA IA ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tips de Seguridad IA",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (!_isLoadingTips)
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
                        onPressed: () {
                          setState(() => _isLoadingTips = true);
                          _loadDynamicTips();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 15),

                if (_isLoadingTips)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                    ),
                  )
                else
                  ..._dynamicTips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTipCard(
                          tip['titulo']!,
                          tip['descripcion']!,
                          Icons.auto_awesome,
                          Colors.green[50]!,
                          Colors.green[700]!,
                        ),
                      )),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildHeader() {
    final String userName = FirebaseAuth.instance.currentUser?.displayName ?? "Usuario";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bienvenido,", style: TextStyle(color: Colors.grey)),
            Text(
              "¡Hola, $userName!",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.person, color: Color(0xFF4CAF50), size: 28),
        ),
      ],
    );
  }

  Widget _buildMainScanCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_scanner, color: Colors.white, size: 60),
          const SizedBox(height: 16),
          const Text(
            "Escanear Menú",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Detecta ingredientes peligrosos en segundos con nuestra IA.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4CAF50),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              minimumSize: const Size(double.infinity, 55),
            ),
            onPressed: () => Navigator.pushNamed(context, '/camera'),
            child: const Text(
              "Iniciar Escaneo con IA",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergySummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "✨La IA buscará estos ingredientes:",
            style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          _userAllergies.isEmpty
              ? const Text("No hay alergias configuradas.", style: TextStyle(color: Colors.grey))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _userAllergies.map((a) => _buildTag(a)).toList(),
                ),
          const Divider(height: 32),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.settings_outlined, size: 18),
            label: const Text("Editar mis alergias"),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF4CAF50)),
          )
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildTipCard(String title, String desc, IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safemenu/service/user_prefs.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final UserPrefs _prefs = UserPrefs();
  List<String> _userAllergies = [];

  @override
  void initState() {
    super.initState();
    _loadAllergies();
  }

  // Carga las alergias guardadas por el usuario
  void _loadAllergies() {
    setState(() {
      _userAllergies = _prefs.allergies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER: SALUDO ---
              _buildHeader(),
              const SizedBox(height: 25),

              // --- TARJETA PRINCIPAL DE ESCANEO ---
              _buildMainScanCard(context),
              const SizedBox(height: 25),

              // --- NUEVA SECCIÓN: RESUMEN DE ALERGIAS ---
              const Text(
                "Mis Alergias Actuales",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildAllergySummaryCard(context),
              const SizedBox(height: 30),

              // --- SECCIÓN: TIPS DE SEGURIDAD ---
              const Text(
                "Consejos de Seguridad",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              _buildTipCard(
                "Verifica siempre",
                "Aunque la IA analice el menú, siempre informa al mesero sobre tu alergia.",
                Icons.security,
                Colors.blue[100]!,
                Colors.blue[700]!,
              ),
              const SizedBox(height: 12),
              _buildTipCard(
                "Contaminación Cruzada",
                "Pregunta si usan utensilios separados para platos con alérgenos.",
                Icons.warning_amber_rounded,
                Colors.orange[100]!,
                Colors.orange[800]!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildHeader() {
    final String userName = FirebaseAuth.instance.currentUser?.displayName ?? "Usuario";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bienvenido,", style: TextStyle(color: Colors.grey)),
            Text(
              "¡Hola, $userName!",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.person, color: Color(0xFF4CAF50), size: 28),
        ),
      ],
    );
  }

  Widget _buildMainScanCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_scanner, color: Colors.white, size: 60),
          const SizedBox(height: 16),
          const Text(
            "Escanear Menú",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Detecta ingredientes peligrosos en segundos con nuestra IA.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4CAF50),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              minimumSize: const Size(double.infinity, 55),
            ),
            onPressed: () => Navigator.pushNamed(context, '/camera'),
            child: const Text(
              "Iniciar Escaneo con IA",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergySummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                "La IA buscará estos ingredientes:",
                style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _userAllergies.isEmpty
              ? const Text("No has configurado alergias aún.", style: TextStyle(color: Colors.grey))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _userAllergies.map((allergy) => _buildAllergyTag(allergy)).toList(),
                ),
          const SizedBox(height: 12),
          const Divider(),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.settings_outlined, size: 18),
            label: const Text("Ajustar mis preferencias"),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4CAF50),
              padding: EdgeInsets.zero,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAllergyTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildTipCard(String title, String desc, IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/