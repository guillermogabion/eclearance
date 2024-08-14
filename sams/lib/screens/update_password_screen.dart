import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SvgPicture
import 'package:e_clearance/api_service.dart';
import 'package:e_clearance/screens/main_screen.dart';

class UpdateScreen extends StatefulWidget {
  final String accessToken;
  const UpdateScreen({
    Key? key,
    required this.accessToken,
  }) : super(key: key);

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final ApiService _apiService = ApiService();

  bool _isPasswordVisible = false; // Manage visibility of password
  bool _isConfirmPasswordVisible =
      false; // Manage visibility of confirm password

  void _updatePassword() {
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    Map<String, dynamic> userData = {
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
    };

    print(userData);

    _performUpdate(userData);
  }

  Future<void> _performUpdate(Map<String, dynamic> userData) async {
    try {
      final response =
          await _apiService.updatePassword(widget.accessToken, userData);
      print('Password updated successfully: $response');
      _navigateToHomeScreen();
    } catch (e) {
      print('Failed to update password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update password. Please try again.'),
        ),
      );
    }
  }

  void _navigateToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(accessToken: widget.accessToken),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Center vertically
            children: <Widget>[
              // SVG Icon
              SvgPicture.asset(
                'assets/images/logo.svg',
                height: 50,
                width: 100,
              ),
              const SizedBox(
                  height: 24.0), // Spacing between the icon and fields

              // New Password TextFormField
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255),
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255),
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color(0xFF4B49AC),
                      width: 2.0,
                    ),
                  ),
                  suffixIcon: IconButton(
                    color: const Color(0xFF4B49AC),
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                onTap: () {
                  setState(() {
                    // Optional: Update focus color if desired
                  });
                },
                onEditingComplete: () {
                  setState(() {
                    // Optional: Update focus color if desired
                  });
                },
              ),
              const SizedBox(height: 12.0),

              // Confirm Password TextFormField
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255),
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255),
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color(0xFF4B49AC),
                      width: 2.0,
                    ),
                  ),
                  suffixIcon: IconButton(
                    color: const Color(0xFF4B49AC),
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                onTap: () {
                  setState(() {
                    // Optional: Update focus color if desired
                  });
                },
                onEditingComplete: () {
                  setState(() {
                    // Optional: Update focus color if desired
                  });
                },
              ),
              const SizedBox(height: 24.0),

              // Update Password Button
              ElevatedButton(
                onPressed: _updatePassword,
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF4B49AC),
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
