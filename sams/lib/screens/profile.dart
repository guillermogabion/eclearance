import 'package:flutter/material.dart';
import 'package:e_clearance/widgets/circle_back.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          // Center(child: CircleBackButton()),
          SizedBox(height: 80),
          Text('Profile Content', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
