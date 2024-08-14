// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Import dart:typed_data
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:e_clearance/api_service.dart';
import 'main_screen.dart'; // Adjust import path as per your project structure
// import 'package:e_clearance/screens/main_screen.dart'; // Import home screen

class RegisterScreen extends StatefulWidget {
  final String accessToken; // Added accessToken

  const RegisterScreen({
    Key? key,
    required this.accessToken,
  }) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _guardianController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  File? _profileImage;
  Uint8List? _webImage;
  String? _fileName;
  final ApiService _apiService = ApiService(); // Instance of ApiService

  @override
  void initState() {
    super.initState();
    // Initialize userIdController with the userId from the response
    // _userIdController.text = widget.response['user']['userId'] ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _profileImage = File('web_image'); // Dummy file for web
          _fileName = pickedFile.name; // Save file name for web
        });
      } else {
        setState(() {
          _profileImage = File(pickedFile.path);
          _fileName = pickedFile.name; // Save file name for non-web
        });
      }
    }
  }

  void _register() {
    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a profile image'),
        ),
      );
      return;
    }

    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    // Construct userData map
    Map<String, dynamic> userData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'guardian': _guardianController.text,
      'address': _addressController.text,
      'contact': _contactController.text,
    };

    _performRegistration(userData);
  }

  Future<void> _performRegistration(Map<String, dynamic> userData) async {
    try {
      // Call register method from ApiService
      Map<String, dynamic> response = await _apiService.register(
          userData, _profileImage!, _fileName!, widget.accessToken);

      // Handle successful registration
      print('User registered successfully: $response');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User Details successfully saved'),
        ),
      );

      // Navigate to HomeScreen upon successful registration
      _navigateToHomeScreen(widget.accessToken);
    } catch (e) {
      // Handle registration failure
      print('Failed to register user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to register user. Please try again.'),
        ),
      );
    }
  }

  void _navigateToHomeScreen(String accessToken) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(accessToken: accessToken),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15.0), // Optional: Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 10.0),
                    const Text(
                      'Please Fill the fields for new User',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 50.0),
                    GestureDetector(
                      onTap: _pickImage,
                      child: SizedBox(
                        width: 100, // Adjust width as needed
                        height: 200,
                        // Adjust height as needed
                        child: Center(
                          child: _profileImage == null
                              ? const Icon(Icons.add_a_photo,
                                  size: 40) // Adjust icon size if needed
                              : kIsWeb
                                  ? Image.memory(_webImage!,
                                      height: 500, fit: BoxFit.cover)
                                  : Image.file(_profileImage!,
                                      height: 500, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      controller: _firstNameController,
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: _guardianController,
                      decoration:
                          const InputDecoration(labelText: 'Guardian/Parent'),
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(labelText: 'Contact'),
                    ),
                    const SizedBox(height: 12.0),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF3b718e), // Background color
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ), // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ))),
    );
  }
}
