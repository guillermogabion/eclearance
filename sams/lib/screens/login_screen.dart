import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'update_password_screen.dart';
import '../api_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  bool _isFocused1 = false;
  bool _isFocused2 = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _login() async {
    String userId = _userIdController.text;
    String password = _passwordController.text;

    if (userId.isEmpty || password.isEmpty) {
      // If fields are empty, show a SnackBar message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return; // Exit the function if validation fails
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> response = await _apiService.login(userId, password);
      setState(() {
        _isLoading = false;
      });

      if (response.containsKey('access_token') &&
          response.containsKey('user')) {
        String accessToken = response['access_token'];
        await _saveAccessToken(accessToken);
        String status = response['user']['status'];

        // _navigateToHomeScreen(accessToken);

        if (status == 'new') {
          _navigateToUpdateScreen(accessToken);
        } else {
          _navigateToHomeScreen(accessToken);
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to Log in. Invalid Credentials.'),
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to Log in. Invalid Credentials.'),
          ),
        );
      });
    }
  }

  Future<void> _saveAccessToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
  }

  void _navigateToHomeScreen(String accessToken) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(accessToken: accessToken),
        ),
      );
    }
  }

  void _navigateToUpdateScreen(String accessToken) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateScreen(accessToken: accessToken),
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(_handleFocusChange1);
    _focusNode2.addListener(_handleFocusChange2);
  }

  void _handleFocusChange1() {
    setState(() {
      _isFocused1 = _focusNode1.hasFocus;
    });
  }

  void _handleFocusChange2() {
    setState(() {
      _isFocused2 = _focusNode2.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode1.removeListener(_handleFocusChange1);
    _focusNode1.dispose();
    _focusNode2.removeListener(_handleFocusChange2);
    _focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 70),
            // const CircleBackButton(),
            const SizedBox(height: 80),
            const Text(
              'Sign In',
              //
              style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 7, 7, 7),
                  letterSpacing: .5,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              focusNode: _focusNode1,
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'User ID',
                labelStyle: TextStyle(
                  color: _isFocused1 ? const Color(0xFF4B49AC) : Colors.grey,
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
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              focusNode: _focusNode2,
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: _isFocused2 ? const Color(0xFF4B49AC) : Colors.grey,
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
            ),
            const SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF4B49AC), // Background color
                  onPrimary: Colors.white, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
