import 'package:flutter/material.dart';
import '../api_service.dart'; // Adjust import path as per your project
import 'package:flutter_svg/flutter_svg.dart';

class HeadBar extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final Function(String) onLogout;
  final Function(String) onSetting;

  const HeadBar({
    Key? key,
    this.userData,
    required this.onLogout,
    required this.onSetting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();

    String? profileUrl;
    if (userData != null && userData!['user'] != null) {
      profileUrl = userData!['user']['profile'];
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: PopupMenuButton<String>(
        onSelected: (String result) {
          if (result == 'logout') {
            onLogout(result);
          } else if (result == 'settings') {
            onSetting(result);
          }
        },
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem<String>(
            value: 'logout',
            child: Text('Logout'),
          ),
          const PopupMenuItem<String>(
            value: 'settings',
            child: Text('Settings'),
          ),
        ],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: profileUrl != null
                  ? NetworkImage('${apiService.baseUrl}/profile/$profileUrl')
                  : null, // Set backgroundImage to null if profileUrl is null
              backgroundColor: Colors.transparent,
              child: profileUrl == null
                  ? SvgPicture.asset(
                      'assets/images/logo.svg',
                      height: 50,
                      width: 100,
                    )
                  : null, // Only show SvgPicture if profileUrl is null
            ),
          ],
        ),
      ),
    );
  }
}
