import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Map<String, dynamic>? userData;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract the role from userData and print it
    final String? role = userData?['user']?['role'];
    print('User Role: $role');

    // Check if the role is 'instructor'
    final bool isInstructor = role == 'instructor';

    // Build the items list based on the role
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.remove_from_queue_rounded),
        label: 'Requests',
      ),
      if (isInstructor) // Add this item only if the user is an instructor
        const BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Class',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: const Color(0xFF4B49AC),
      unselectedItemColor: Colors.grey,
      items: items,
    );
  }
}
