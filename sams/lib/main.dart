import 'package:flutter/material.dart';
import 'routes/app_router.dart'; // Import your app router

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Clearance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Set initial route to LoginScreen
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
