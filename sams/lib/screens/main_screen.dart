import 'dart:math'; // Import to use Random class
import 'package:flutter/material.dart';
import 'package:e_clearance/api_service.dart'; // Adjust import path as per your project structure
import 'package:e_clearance/screens/class.dart';
import 'package:e_clearance/screens/profile.dart';
import 'package:e_clearance/screens/register_screen.dart';
import 'package:e_clearance/screens/login_screen.dart';
import 'package:e_clearance/screens/dashboard.dart';
import 'package:e_clearance/screens/requests.dart';
import 'package:e_clearance/screens/send_request.dart';
import 'package:e_clearance/screens/start.dart';
import 'package:e_clearance/widgets/bottom_navbar.dart';
import 'package:e_clearance/widgets/head_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final String accessToken;

  const MainScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  String _userRole = '';
  bool _isLoading = false;
  int _selectedIndex = 0;

  final List<String> _morningPhrases = ["Good Morning!"];
  final List<String> _noonPhrases = ["Good Afternoon"];
  final List<String> _eveningPhrases = ["Good Evening!"];

  double _fabX = 0.0;
  double _fabY = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    // Set initial position of the FloatingActionButton to the bottom-right corner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _fabX = size.width - 70; // Adjust based on FAB size and padding
        _fabY = size.height - 165; // Adjust based on FAB size and padding
      });
    });
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _apiService.fetchSelf(widget.accessToken);
      setState(() {
        _userData = userData;
        _userRole = _userData?['user']['role'] ?? ''; // Set the role here
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout(String action) async {
    if (action == 'logout') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const StartHomeScreen()),
        (route) => false,
      );
    }
  }

  void _setting(String action) {
    if (action == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterScreen(
            accessToken: widget.accessToken, // Use widget.accessToken here
          ),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    final random = Random();

    if (hour < 12) {
      return _morningPhrases[random.nextInt(_morningPhrases.length)];
    } else if (hour < 18) {
      return _noonPhrases[random.nextInt(_noonPhrases.length)];
    } else {
      return _eveningPhrases[random.nextInt(_eveningPhrases.length)];
    }
  }

  String getGreeting() {
    if (_userData != null && _userData!['firstName'] != null) {
      String name = _userData!['firstName'];
      return 'Hi $name!';
    } else {
      return 'Hi Guest!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _userData != null
                  ? _userRole == 'instructor'
                      ? _selectedIndex == 0
                          ? const Dashboard()
                          : _selectedIndex == 1
                              ? Requests(
                                  accessToken: widget.accessToken,
                                  apiService: _apiService,
                                  userRole: _userRole,
                                )
                              : _selectedIndex == 2
                                  ? const Class()
                                  : const Profile()
                      : _selectedIndex == 0
                          ? const Dashboard()
                          : _selectedIndex == 1
                              ? Requests(
                                  accessToken: widget.accessToken,
                                  apiService: _apiService,
                                  userRole: _userRole,
                                )
                              : const Profile()
                  : const Center(
                      child: Text(
                        'User data not available',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: HeadBar(
                userData: _userData,
                onLogout: _logout,
                onSetting: _setting,
              ),
            ),
          ),
          Positioned(
            left: _fabX,
            top: _fabY,
            child: Draggable(
              feedback: _buildFloatingButton(),
              childWhenDragging: Container(),
              onDragUpdate: (details) {
                setState(() {
                  _fabX = max(0.0, details.globalPosition.dx - 28);
                  _fabY = max(0.0, details.globalPosition.dy - 28);
                });
              },
              child: _buildFloatingButton(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        userData: _userData,
      ),
    );
  }

  Widget _buildFloatingButton() {
    final bool isStudent = _userRole == 'student';
    return isStudent
        ? FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddRequest(
                      userData: _userData, accessToken: widget.accessToken),
                ),
              );
            },
            backgroundColor: const Color(0xFF4B49AC),
            child: const Icon(Icons.add),
          )
        : const SizedBox.shrink();
  }
}
