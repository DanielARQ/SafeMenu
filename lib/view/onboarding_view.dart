import 'package:flutter/material.dart';
import '../controller/onboarding_controller.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  _OnboardingViewState createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final OnboardingController _controller = OnboardingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // Agregamos un LayoutBuilder para manejar mejor los tamaños
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // <--- LA SOLUCIÓN AL OVERFLOW
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 550, // Altura fija para el área de contenido
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) =>
                                setState(() => _currentPage = index),
                            itemCount: _controller.steps.length,
                            itemBuilder: (context, index) {
                              final step = _controller.steps[index];
                              return Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // REEMPLAZAMOS EL CONTENEDOR DE LA IMAGEN POR UNO PARA EL ICONO
                                    // En onboarding_view.dart
                                    Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF4CAF50,
                                        ).withOpacity(0.1), // Fondo verde suave
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF4CAF50,
                                          ).withOpacity(0.2),
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          step.icon,
                                          size: 140,
                                          color: const Color(0xFF4CAF50),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Text(
                                      step.title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      step.description,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Indicadores
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _controller.steps.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Botón
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            if (_currentPage < _controller.steps.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            } else {
                              Navigator.pushReplacementNamed(context, '/');
                            }
                          },
                          // Dentro del ElevatedButton en onboarding_view.dart
                          child: Text(
                            _currentPage == _controller.steps.length - 1
                                ? 'Comenzar'
                                : 'Siguiente',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
