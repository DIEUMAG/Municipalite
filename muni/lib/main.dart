import 'package:flutter/material.dart';
import 'app.dart';

import 'core/routes/app_routes.dart';

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      initialRoute: AppRoutes.login,

      routes: AppRoutes.routes,
    );
  }
}