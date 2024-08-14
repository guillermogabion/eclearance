import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:e_clearance/auth_service.dart'; // Import the new AuthService file
import 'package:e_clearance/screens/login_screen.dart';
import 'package:e_clearance/screens/main_screen.dart';

class StartHomeScreen extends StatefulWidget {
  const StartHomeScreen({Key? key}) : super(key: key);

  @override
  _StartHomeScreenState createState() => _StartHomeScreenState();
}

class _StartHomeScreenState extends State<StartHomeScreen> {
  final AuthService _authService = AuthService();

  Future<String?> _checkAuthenticationStatus() async {
    String? accessToken = await _authService.getAccessToken();

    if (accessToken != null) {
      try {
        bool isValid = await _authService.validateToken(accessToken);
        if (isValid) {
          return accessToken; // Valid token
        } else {
          return null; // Invalid token
        }
      } catch (e) {
        return null; // Error occurred
      }
    } else {
      return null; // No token found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<String?>(
          future: _checkAuthenticationStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              return MainScreen(accessToken: snapshot.data!);
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/logo.svg',
                      height: 50,
                      width: 100,
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF4B49AC),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Have an Account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFF1b2b36),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
