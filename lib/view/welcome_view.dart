import 'package:flutter/material.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF4CAF50);
    const Color dark = Color(0xFF0B1533);
    const Color subtitle = Color(0xFF5E6F8D);
    const Color lightBg = Color(0xFFF6F7F5);
    const Color paleGreen = Color(0xFFEAF3EA);

    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "9:41",
                        style: TextStyle(
                          color: dark,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 190,
                        height: 190,
                        decoration: const BoxDecoration(
                          color: paleGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant,
                            size: 80,
                            color: green,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: green,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  const Text(
                    "SafeMenu",
                    style: TextStyle(
                      color: green,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Eat safely,\neverywhere.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: dark,
                      fontSize: 34,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      "Scan menus. Detect allergens.\nDine with confidence.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subtitle,
                        fontSize: 18,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF3EA),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(0),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 62,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: green,
                              foregroundColor: Colors.white,
                              elevation: 6,
                              shadowColor: green.withOpacity(0.25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            icon: const Icon(Icons.login),
                            label: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 62,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: green,
                              side: const BorderSide(color: green, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
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