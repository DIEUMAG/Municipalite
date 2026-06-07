import 'package:flutter/material.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/landing_page.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';

class AppRoutes {
  static const String landing = '/landing';
  static const String login = '/';
  static const String register = '/register';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    landing: (context) => const LandingScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
  };
}