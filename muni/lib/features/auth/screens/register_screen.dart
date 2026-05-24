import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../../../core/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final usernameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> register() async {
    setState(() {
      isLoading = true;
    });

    try {
      print("REGISTER STARTED");

      final response =
          await authService.register(
        username:
            usernameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber:
            phoneController.text.trim(),
        password:
            passwordController.text.trim(),
      );

      print(
          "REGISTER RESPONSE => $response");

      if (response.isNotEmpty) {
        print("REGISTER SUCCESS");

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
        );
      } else {
        showMessage(
          "Registration failed",
        );
      }
    } catch (e) {
      print("REGISTER ERROR => $e");

      showMessage(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor:
            Colors.redAccent,
        behavior:
            SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
        content: Text(message),
      ),
    );
  }

  InputDecoration customInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF1565C0),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFF1565C0),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1565C0),
              Color(0xFF42A5F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(24),
              child: Container(
                padding:
                    const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    30,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.1),
                      blurRadius: 20,
                      offset:
                          const Offset(
                        0,
                        10,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets
                              .all(20),
                      decoration:
                          BoxDecoration(
                        color: const Color(
                          0xFF1565C0,
                        ).withOpacity(0.1),
                        shape:
                            BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add,
                        size: 60,
                        color:
                            Color(0xFF1565C0),
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF1565C0),
                      ),
                    ),

                    const SizedBox(
                        height: 8),

                    Text(
                      'Inscrivez-vous pour continuer',
                      style: TextStyle(
                        color:
                            Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(
                        height: 35),

                    TextField(
                      controller:
                          usernameController,
                      decoration:
                          customInputDecoration(
                        hint:
                            'Nom utilisateur',
                        icon:
                            Icons.person,
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    TextField(
                      controller:
                          emailController,
                      decoration:
                          customInputDecoration(
                        hint: 'Email',
                        icon:
                            Icons.email,
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    TextField(
                      controller:
                          phoneController,
                      decoration:
                          customInputDecoration(
                        hint:
                            'Téléphone',
                        icon:
                            Icons.phone,
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    TextField(
                      controller:
                          passwordController,
                      obscureText:
                          obscurePassword,
                      decoration:
                          customInputDecoration(
                        hint:
                            'Mot de passe',
                        icon: Icons.lock,
                        suffixIcon:
                            IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons
                                    .visibility_off
                                : Icons
                                    .visibility,
                            color:
                                Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 35),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 58,
                      child:
                          ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : register,
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF1565C0,
                          ),
                          elevation: 5,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              18,
                            ),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors
                                    .white,
                              )
                            : const Text(
                                'Créer un compte',
                                style:
                                    TextStyle(
                                  fontSize:
                                      18,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Text(
                          "Déjà un compte ?",
                          style: TextStyle(
                            color: Colors
                                .grey.shade600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator
                                .pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                          child: const Text(
                            'Connexion',
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color:
                                  Color(
                                0xFF1565C0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}