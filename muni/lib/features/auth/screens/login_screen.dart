import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final usernameController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await authService.login(
        username:
            usernameController.text.trim(),
        password:
            passwordController.text.trim(),
      );

      print(
          "LOGIN RESPONSE => $response");

      if (response['access'] != null) {
        print("LOGIN SUCCESS");

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
        );
      } else {
        print("LOGIN FAILED");

        showMessage(
          response.toString(),
        );
      }
    } catch (e) {
      print("ERROR => $e");

      showMessage(e.toString());
    }

    setState(() {
      isLoading = false;
    });
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
                        Icons.account_balance,
                        size: 60,
                        color:
                            Color(0xFF1565C0),
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    const Text(
                      'Bienvenue',
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
                      'Connectez-vous à votre compte',
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
                        height: 30),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 58,
                      child:
                          ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                    print(
                                        "LOGIN BUTTON CLICKED");

                                    login();
                                  },
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
                                'Connexion',
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
                          "Pas de compte ?",
                          style: TextStyle(
                            color: Colors
                                .grey.shade600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator
                                .pushNamed(
                              context,
                              AppRoutes
                                  .register,
                            );
                          },
                          child: const Text(
                            'Créer un compte',
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