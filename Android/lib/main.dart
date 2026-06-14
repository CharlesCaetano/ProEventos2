// ============================================================
// ERP 2026 - FASE 8 - App Mobile Flutter
// Descrição: Aplicativo Android para acesso ao ERP
// ============================================================

import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const ERP2026App());
}

class ERP2026App extends StatelessWidget {
  const ERP2026App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
