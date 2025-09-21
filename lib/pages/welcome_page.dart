import 'package:flutter/material.dart';
import 'package:lotto/pages/login.dart';
import 'register.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7EC3FF), Color(0xFF59AFFB)],
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        'assets/images/Logo.png',
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 0),
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 25, 25, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Welcome to\nLotto 888",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0593FF),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Color(0xFF0593FF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                            },
                            child: const Text("Login",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              elevation: 2,
                              side: BorderSide(
                                  color: Color(0xFF0593FF), width: 2),
                              foregroundColor: scheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Register()));
                            },
                            child: const Text(
                              "Sign up",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0593FF),
                              ),
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
        ),
      ),
    );
  }
}
