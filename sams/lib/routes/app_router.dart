import 'package:flutter/material.dart';
import 'package:e_clearance/screens/start.dart'; // Import your login screen

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const StartHomeScreen());
      // return MaterialPageRoute(builder: (_) => const LoginScreen());
      // Add more routes here if needed
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Page not found'),
        ),
      );
    });
  }
}
